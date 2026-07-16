import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/trade_plan.dart';
import '../models/trading_rule.dart';

class DataExportService {
  static Map<String, dynamic> buildExportData({
    required List<TradePlan> tradePlans,
    required List<TradingRule> tradingRules,
  }) {
    return {
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'data': {
        'trade_plans': tradePlans.map((p) => p.toMap()).toList(),
        'trading_rules': tradingRules.map((r) => r.toMap()).toList(),
      },
    };
  }

  /// 生成交易计划 CSV 内容
  static String _buildTradePlansCsv(List<TradePlan> tradePlans) {
    final lines = <String>[];
    // CSV 表头
    lines.add(
      '股票代码,股票名称,买入价格,止损价格,目标价格,仓位比例,'
      '买入条件,卖出条件,最大买入数量(手),最大买入金额(元),'
      '允许做T,计划制定日期,买入理由,执行总结,'
      '执行买入日期,执行卖出日期,执行买入价格,执行卖出价格,'
      '买入数量(手),买入总金额(元),卖出总金额(元),是否有做T,'
      '执行仓位,收益率,与计划一致,状态,创建日期',
    );

    for (final p in tradePlans) {
      final row = [
        _csvEscape(p.stockCode),
        _csvEscape(p.stockName),
        p.buyPrice.toString(),
        p.stopLossPrice.toString(),
        p.targetPrice.toString(),
        p.positionRatio.toString(),
        _csvEscape(p.buyCondition ?? ''),
        _csvEscape(p.sellCondition ?? ''),
        p.maxBuyQuantity?.toString() ?? '',
        p.maxBuyAmount?.toString() ?? '',
        p.allowT ? '是' : '否',
        p.plannedDate?.toLocal().toString().split(' ')[0] ?? '',
        _csvEscape(p.reason),
        _csvEscape(p.executionNote ?? ''),
        p.executedAt?.toLocal().toString().split(' ')[0] ?? '',
        p.executedSellDate?.toLocal().toString().split(' ')[0] ?? '',
        p.executedBuyPrice?.toString() ?? '',
        p.executedSellPrice?.toString() ?? '',
        p.buyQuantity?.toString() ?? '',
        p.buyTotalAmount?.toString() ?? '',
        p.sellTotalAmount?.toString() ?? '',
        p.didT == null ? '' : (p.didT! ? '是' : '否'),
        p.executedPositionRatio?.toString() ?? '',
        p.executedReturnRate?.toString() ?? '',
        _csvEscape(p.status.name),
        p.createdAt.toLocal().toString().split(' ')[0],
      ];
      lines.add(row.join(','));
    }

    // 添加 UTF-8 BOM 以便 Excel 正确识别中文
    return '\uFEFF${lines.join('\r\n')}';
  }

  /// 生成交易原则 CSV 内容
  static String _buildTradingRulesCsv(List<TradingRule> rules) {
    final lines = <String>[];
    lines.add('序号,内容,是否必选');
    for (final r in rules) {
      lines.add(
        '${r.sortOrder},${_csvEscape(r.content)},${r.required ? "是" : "否"}',
      );
    }
    return '\uFEFF${lines.join('\r\n')}';
  }

  /// CSV 字段转义（处理包含逗号、引号、换行的内容）
  static String _csvEscape(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// 保存 CSV 文件
  static Future<String> saveCsvFile({
    required List<TradePlan> tradePlans,
    required List<TradingRule> tradingRules,
  }) async {
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;

    // 生成计划CSV
    final plansCsv = _buildTradePlansCsv(tradePlans);
    final plansFileName = 'trade_plans_$timestamp.csv';

    // 生成原则CSV
    final rulesCsv = _buildTradingRulesCsv(tradingRules);
    final rulesFileName = 'trading_rules_$timestamp.csv';

    // Android: 保存到公共 Download 目录
    try {
      final dir = Directory('/storage/emulated/0/Download');
      if (await dir.exists()) {
        await File('${dir.path}/$plansFileName').writeAsString(plansCsv);
        await File('${dir.path}/$rulesFileName').writeAsString(rulesCsv);
        return '${dir.path}/$plansFileName\n${dir.path}/$rulesFileName';
      }
    } catch (_) {}

    // 降级：保存到应用文档目录
    final dir = await getApplicationDocumentsDirectory();
    await File('${dir.path}/$plansFileName').writeAsString(plansCsv);
    await File('${dir.path}/$rulesFileName').writeAsString(rulesCsv);
    return '${dir.path}/$plansFileName\n${dir.path}/$rulesFileName';
  }

  /// 保存 JSON 文件
  static Future<String> saveExportFile({
    required List<TradePlan> tradePlans,
    required List<TradingRule> tradingRules,
  }) async {
    final data = buildExportData(
      tradePlans: tradePlans,
      tradingRules: tradingRules,
    );
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final fileName = 'trade_guardian_backup_$timestamp.json';

    // Android: 保存到公共 Download 目录
    try {
      final dir = Directory('/storage/emulated/0/Download');
      if (await dir.exists()) {
        final file = File('${dir.path}/$fileName');
        await file.writeAsString(jsonString);
        return file.path;
      }
    } catch (_) {}

    // 降级：保存到应用文档目录
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(jsonString);

    return file.path;
  }
}

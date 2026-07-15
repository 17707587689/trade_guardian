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

  /// 保存 JSON 文件到 Download 目录
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

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/trade_plan.dart';
import '../models/trading_rule.dart';

class DataExportService {
  /// 导出数据为 JSON 字符串
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

  /// 保存 JSON 到文件并通过系统分享发送
  static Future<void> shareExportFile({
    required List<TradePlan> tradePlans,
    required List<TradingRule> tradingRules,
  }) async {
    final data = buildExportData(
      tradePlans: tradePlans,
      tradingRules: tradingRules,
    );
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final file = File('${dir.path}/trade_guardian_backup_$timestamp.json');
    await file.writeAsString(jsonString);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: 'TradeGuardian 数据备份'),
    );
  }
}

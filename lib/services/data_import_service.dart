import 'dart:convert';
import 'dart:io';

import '../models/trade_plan.dart';
import '../models/trading_rule.dart';
import '../repositories/trade_plan_repository.dart';
import '../repositories/trading_rule_repository.dart';

class DataImportService {
  final TradePlanRepository _planRepo;
  final TradingRuleRepository _ruleRepo;

  DataImportService({
    TradePlanRepository? planRepo,
    TradingRuleRepository? ruleRepo,
  }) : _planRepo = planRepo ?? TradePlanRepository(),
       _ruleRepo = ruleRepo ?? TradingRuleRepository();

  /// 清空所有数据
  Future<void> clearAllData() async {
    final db = await _planRepo.getDatabase();
    await db.delete('trade_plans');
    await db.delete('trading_rules');
  }

  /// 从 JSON 字符串解析并导入数据
  /// [overwrite] 为 true 时先清空原有数据再导入
  /// 返回导入统计信息
  Future<ImportResult> importFromJson(
    String jsonString, {
    bool overwrite = false,
  }) async {
    final data = json.decode(jsonString) as Map<String, dynamic>;

    // 校验格式
    if (data['version'] == null || data['data'] == null) {
      throw FormatException('无效的备份文件格式');
    }

    // 覆盖模式：先清空数据
    if (overwrite) {
      await clearAllData();
    }

    final dataMap = data['data'] as Map<String, dynamic>;
    int planCount = 0;
    int ruleCount = 0;
    List<String> errors = [];

    // 导入交易计划
    if (dataMap.containsKey('trade_plans')) {
      final plans = dataMap['trade_plans'] as List;
      for (final planJson in plans) {
        try {
          final planMap = Map<String, dynamic>.from(planJson);
          // 移除 id 让数据库自动分配
          planMap.remove('id');
          final plan = TradePlan.fromMap(planMap);
          await _planRepo.insertPlan(plan);
          planCount++;
        } catch (e) {
          errors.add('导入交易计划失败: $e');
        }
      }
    }

    // 导入交易原则
    if (dataMap.containsKey('trading_rules')) {
      final rules = dataMap['trading_rules'] as List;
      for (final ruleJson in rules) {
        try {
          final ruleMap = Map<String, dynamic>.from(ruleJson);
          ruleMap.remove('id');
          final rule = TradingRule.fromMap(ruleMap);
          await _ruleRepo.insertRule(rule);
          ruleCount++;
        } catch (e) {
          errors.add('导入交易原则失败: $e');
        }
      }
    }

    return ImportResult(
      planCount: planCount,
      ruleCount: ruleCount,
      errors: errors,
    );
  }

  /// 从文件导入
  Future<ImportResult> importFromFile(
    File file, {
    bool overwrite = false,
  }) async {
    final jsonString = await file.readAsString();
    return importFromJson(jsonString, overwrite: overwrite);
  }
}

class ImportResult {
  final int planCount;
  final int ruleCount;
  final List<String> errors;

  const ImportResult({
    required this.planCount,
    required this.ruleCount,
    this.errors = const [],
  });

  bool get hasErrors => errors.isNotEmpty;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('导入完成：');
    buffer.writeln('  - 交易计划: $planCount 条');
    buffer.writeln('  - 交易原则: $ruleCount 条');
    if (hasErrors) {
      buffer.writeln('  - 错误: ${errors.length} 个');
      for (final error in errors) {
        buffer.writeln('    * $error');
      }
    }
    return buffer.toString();
  }
}

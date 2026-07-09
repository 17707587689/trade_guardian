import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trade_guardian/database/database_helper.dart';
import 'package:trade_guardian/models/trading_rule.dart';
import 'package:trade_guardian/repositories/trading_rule_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('TradingRuleRepository 插入并读取默认纪律', () async {
    final repository = TradingRuleRepository();

    await repository.ensureDefaultRules();
    final rules = await repository.getAllRules();

    expect(
      rules.length,
      greaterThanOrEqualTo(TradingRuleRepository.defaultRules.length),
    );
    expect(rules.any((rule) => rule.content == '我不会追涨。'), true);
    expect(rules.any((rule) => rule.sortOrder == 1), true);

    await DatabaseHelper.instance.close();
  });

  test('TradingRuleRepository 支持新增纪律', () async {
    final repository = TradingRuleRepository();
    final id = await repository.insertRule(
      const TradingRule(content: '测试规则', sortOrder: 99),
    );

    final rules = await repository.getAllRules();

    expect(id, greaterThan(0));
    expect(rules.any((rule) => rule.content == '测试规则'), true);

    await DatabaseHelper.instance.close();
  });
}

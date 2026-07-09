import 'package:flutter_test/flutter_test.dart';

import 'package:trade_guardian/models/trading_rule.dart';

void main() {
  test('TradingRule 创建成功', () {
    const rule = TradingRule(
      id: 1,
      content: '交易计划必须提前一天制定',
      sortOrder: 1,
      required: true,
    );

    expect(rule.id, 1);
    expect(rule.content, '交易计划必须提前一天制定');
    expect(rule.sortOrder, 1);
    expect(rule.required, true);
  });

  test('TradingRule toMap()', () {
    const rule = TradingRule(
      id: 1,
      content: '买入前必须设置止损',
      sortOrder: 2,
      required: true,
    );

    final map = rule.toMap();

    expect(map['id'], 1);
    expect(map['content'], '买入前必须设置止损');
    expect(map['sort_order'], 2);
    expect(map['required'], 1);
  });

  test('TradingRule fromMap()', () {
    final map = {'id': 2, 'content': '我不会追涨', 'sort_order': 3, 'required': 0};

    final rule = TradingRule.fromMap(map);

    expect(rule.id, 2);
    expect(rule.content, '我不会追涨');
    expect(rule.sortOrder, 3);
    expect(rule.required, false);
  });
}

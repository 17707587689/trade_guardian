import 'package:flutter_test/flutter_test.dart';
import 'package:trade_guardian/models/trade_plan.dart';

void main() {
  test('TradePlan 创建成功', () {
    final plan = TradePlan(
      stockCode: '600519',
      stockName: '贵州茅台',
      buyPrice: 1500,
      stopLossPrice: 1450,
      targetPrice: 1700,
      positionRatio: 20,
      reason: '测试',
      createdAt: DateTime.now(),
    );

    expect(plan.stockCode, '600519');
    expect(plan.stockName, '贵州茅台');
    expect(plan.status, TradePlanStatus.draft);
  });
}

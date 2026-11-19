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

  test('复制交易计划时不保留旧的 id', () {
    final original = TradePlan(
      id: 123,
      stockCode: '000001',
      stockName: '平安银行',
      buyPrice: 10,
      stopLossPrice: 9,
      targetPrice: 12,
      positionRatio: 15,
      reason: '测试复制',
      createdAt: DateTime(2024, 1, 1),
    );

    final copied = original.copyWith(
      id: null,
      stockName: '${original.stockName}（复制）',
      createdAt: DateTime(2024, 1, 2),
    );

    expect(copied.id, isNull);
    expect(copied.toMap().containsKey('id'), isFalse);
  });

  test('复制交易计划时清空执行字段', () {
    final original = TradePlan(
      id: 123,
      stockCode: '000001',
      stockName: '平安银行',
      buyPrice: 10,
      stopLossPrice: 9,
      targetPrice: 12,
      positionRatio: 15,
      reason: '测试复制',
      executedAt: DateTime(2024, 1, 10),
      executedBuyPrice: 9.5,
      executedSellPrice: 10.8,
      executedSellDate: DateTime(2024, 1, 12),
      executedPositionRatio: 20,
      executedMatched: true,
      executedReturnRate: 0.12,
      createdAt: DateTime(2024, 1, 1),
    );

    final copied = original.copyWith(
      id: null,
      stockName: '${original.stockName}（复制）',
      createdAt: DateTime(2024, 1, 2),
      executedAt: null,
      executedBuyPrice: null,
      executedSellPrice: null,
      executedSellDate: null,
      executedPositionRatio: null,
      executedMatched: null,
      executedReturnRate: null,
    );

    expect(copied.id, isNull);
    expect(copied.executedAt, isNull);
    expect(copied.executedBuyPrice, isNull);
    expect(copied.executedSellPrice, isNull);
    expect(copied.executedSellDate, isNull);
    expect(copied.executedPositionRatio, isNull);
    expect(copied.executedMatched, isNull);
    expect(copied.executedReturnRate, isNull);
  });

  test('收益率格式化为百分比', () {
    expect(TradePlan.formatPercentage(0.125, fractionDigits: 2), '+12.50%');
    expect(TradePlan.formatPercentage(-0.125, fractionDigits: 2), '-12.50%');
  });
}

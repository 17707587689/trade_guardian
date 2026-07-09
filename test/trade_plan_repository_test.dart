import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trade_guardian/models/trade_plan.dart';
import 'package:trade_guardian/repositories/trade_plan_repository.dart';

void main() {
  group('TradePlanRepository', () {
    late TradePlanRepository repo;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      repo = TradePlanRepository();
    });

    test('insert, getAll, update and delete plan', () async {
      // insert
      final plan = TradePlan(
        stockCode: '000001',
        stockName: 'TestStock',
        buyPrice: 10.0,
        stopLossPrice: 9.0,
        targetPrice: 12.0,
        positionRatio: 0.1,
        reason: 'unit test',
        createdAt: DateTime.now(),
      );

      final id = await repo.insertPlan(plan);
      expect(id, greaterThan(0));

      // getAll contains the new plan
      final all = await repo.getAllPlans();
      expect(
        all.any((p) => p.stockCode == '000001' && p.stockName == 'TestStock'),
        isTrue,
      );

      // getById
      final fetched = await repo.getPlanById(id);
      expect(fetched, isNotNull);
      expect(fetched!.stockCode, equals('000001'));

      // update
      final updated = fetched.copyWith(stockName: 'UpdatedStock');
      final updatedCount = await repo.updatePlan(updated);
      expect(updatedCount, greaterThan(0));

      final fetched2 = await repo.getPlanById(id);
      expect(fetched2!.stockName, equals('UpdatedStock'));

      // delete
      final delCount = await repo.deletePlan(id);
      expect(delCount, greaterThan(0));

      final fetched3 = await repo.getPlanById(id);
      expect(fetched3, isNull);
    });
  });
}

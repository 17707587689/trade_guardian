import '../database/database_helper.dart';
import '../models/trade_plan.dart';
import '../models/execution_statistic.dart';

class TradePlanRepository {
  TradePlanRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<List<TradePlan>> getAllPlans() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('trade_plans', orderBy: 'created_at DESC');

    return maps.map(TradePlan.fromMap).toList();
  }

  Future<TradePlan?> getPlanById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'trade_plans',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return TradePlan.fromMap(maps.first);
  }

  Future<int> insertPlan(TradePlan plan) async {
    final db = await _databaseHelper.database;
    return db.insert('trade_plans', plan.toMap());
  }

  Future<int> updatePlan(TradePlan plan) async {
    if (plan.id == null) {
      throw ArgumentError('更新交易计划需要 id');
    }

    final db = await _databaseHelper.database;
    return db.update(
      'trade_plans',
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  Future<int> deletePlan(int id) async {
    final db = await _databaseHelper.database;
    return db.delete('trade_plans', where: 'id = ?', whereArgs: [id]);
  }

  Future<ExecutionStatistic> getExecutionStatistic(Duration duration) async {
    final plans = await getAllPlans();

    final now = DateTime.now();

    final start = now.subtract(duration);

    final completedPlans = plans.where((p) {
      if (p.status != TradePlanStatus.completed) {
        return false;
      }

      if (p.executedSellDate == null) {
        return false;
      }

      return p.executedSellDate!.isAfter(start);
    }).toList();

    final matched = completedPlans
        .where((p) => p.executedMatched == true)
        .length;

    return ExecutionStatistic(matched: matched, total: completedPlans.length);
  }
}

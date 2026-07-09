import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/trading_rule.dart';

class TradingRuleRepository {
  TradingRuleRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  static const List<TradingRule> defaultRules = [
    TradingRule(content: '我不会追涨。', sortOrder: 1),
    TradingRule(content: '买入前必须设置止损。', sortOrder: 2),
    TradingRule(content: '单只股票仓位不得超过计划比例。', sortOrder: 3),
    TradingRule(content: '每笔交易必须提前一天制定计划。', sortOrder: 4),
  ];

  Future<List<TradingRule>> getAllRules() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('trading_rules', orderBy: 'sort_order ASC');

    return maps.map(TradingRule.fromMap).toList();
  }

  Future<void> ensureDefaultRules() async {
    final db = await _databaseHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM trading_rules'),
    );

    if (count != 0) {
      return;
    }

    final batch = db.batch();
    for (final rule in defaultRules) {
      batch.insert('trading_rules', rule.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<int> insertRule(TradingRule rule) async {
    final db = await _databaseHelper.database;
    return db.insert('trading_rules', rule.toMap());
  }

  Future<int> updateRule(TradingRule rule) async {
    if (rule.id == null) {
      throw ArgumentError('更新交易纪律需要 id');
    }

    final db = await _databaseHelper.database;
    return db.update(
      'trading_rules',
      rule.toMap(),
      where: 'id = ?',
      whereArgs: [rule.id],
    );
  }

  Future<int> deleteRule(int id) async {
    final db = await _databaseHelper.database;
    return db.delete('trading_rules', where: 'id = ?', whereArgs: [id]);
  }
}

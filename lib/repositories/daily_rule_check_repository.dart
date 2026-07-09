import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

class DailyRuleCheckRepository {
  DailyRuleCheckRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<bool> isConfirmedFor(DateTime date) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'daily_rule_checks',
      where: 'check_date = ?',
      whereArgs: [_dateKey(date)],
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  Future<void> confirmFor(DateTime date) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now().toIso8601String();

    await db.insert(
      'daily_rule_checks',
      {
        'check_date': _dateKey(date),
        'confirmed_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

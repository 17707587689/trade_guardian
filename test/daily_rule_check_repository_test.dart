import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trade_guardian/database/database_helper.dart';
import 'package:trade_guardian/repositories/daily_rule_check_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('DailyRuleCheckRepository 记录今日确认状态', () async {
    final repository = DailyRuleCheckRepository();
    final date = DateTime(2026, 7, 9);
    final db = await DatabaseHelper.instance.database;

    await db.delete(
      'daily_rule_checks',
      where: 'check_date = ?',
      whereArgs: ['2026-07-09'],
    );

    expect(await repository.isConfirmedFor(date), false);

    await repository.confirmFor(date);

    expect(await repository.isConfirmedFor(date), true);

    await DatabaseHelper.instance.close();
  });
}

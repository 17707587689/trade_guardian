import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:trade_guardian/database/database_helper.dart';

void main() {
  setUpAll(() {
    databaseFactory = databaseFactoryFfi;
  });

  test('数据库初始化测试', () async {
    final db = await DatabaseHelper.instance.database;

    expect(db.isOpen, true);

    final tables = await db.rawQuery('''
            SELECT name 
            FROM sqlite_master 
            WHERE type='table'
            ''');

    final tableNames = tables.map((e) => e['name']).toList();

    expect(tableNames.contains('trade_plans'), true);

    expect(tableNames.contains('trading_rules'), true);

    await db.close();
  });
}

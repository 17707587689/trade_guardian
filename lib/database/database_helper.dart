import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('trade_guardian.db');

    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, fileName);

    return await openDatabase(
      path,

      // 当前数据库版本
      version: 12,

      onCreate: _createDB,

      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''

      CREATE TABLE trade_plans (

        id INTEGER PRIMARY KEY AUTOINCREMENT,

        stock_code TEXT NOT NULL,

        stock_name TEXT NOT NULL,

        buy_price REAL NOT NULL,

        stop_loss_price REAL NOT NULL,

        target_price REAL NOT NULL,

        position_ratio REAL NOT NULL,

        reason TEXT NOT NULL,

        buy_condition_1 TEXT,

        buy_condition_2 TEXT,

        buy_condition_3 TEXT,

        sell_condition_1 TEXT,

        sell_condition_2 TEXT,

        sell_condition_3 TEXT,

        execution_note TEXT,

        allow_t INTEGER DEFAULT 0,

        planned_date TEXT,


        -- 交易计划状态
        status TEXT NOT NULL,


        -- 实际执行信息
        executed_at TEXT,

        executed_buy_price REAL,

        executed_sell_price REAL,

        executed_sell_date TEXT,

        executed_position_ratio REAL,


        -- 是否符合计划
        executed_matched INTEGER DEFAULT 0,


        -- 实际收益率
        executed_return_rate REAL,


        created_at TEXT NOT NULL,

        max_buy_quantity REAL,
        max_buy_amount REAL,
        buy_quantity REAL,
        buy_total_amount REAL,
        sell_total_amount REAL,
        did_t INTEGER DEFAULT 0

      )

    ''');

    await db.execute('''

      CREATE TABLE trading_rules (

        id INTEGER PRIMARY KEY AUTOINCREMENT,

        content TEXT NOT NULL,

        sort_order INTEGER NOT NULL,

        required INTEGER NOT NULL

      )

    ''');

    await db.execute('''

      CREATE TABLE daily_rule_checks (

        id INTEGER PRIMARY KEY AUTOINCREMENT,

        check_date TEXT NOT NULL UNIQUE,

        confirmed_at TEXT NOT NULL

      )

    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // v9 增加计划制定日期字段
    if (oldVersion < 9) {
      await db.execute('''
ALTER TABLE trade_plans ADD COLUMN planned_date TEXT;
''');
    }
    // v10 增加最大买入金额字段
    if (oldVersion < 10) {
      await db.execute('''
ALTER TABLE trade_plans ADD COLUMN max_buy_amount REAL;
''');
    }
    // v11 增加执行信息字段
    if (oldVersion < 11) {
      await db.execute('''
ALTER TABLE trade_plans ADD COLUMN max_buy_quantity REAL;
''');
      await db.execute('''
ALTER TABLE trade_plans ADD COLUMN buy_quantity REAL;
''');
      await db.execute('''
ALTER TABLE trade_plans ADD COLUMN buy_total_amount REAL;
''');
      await db.execute('''
ALTER TABLE trade_plans ADD COLUMN sell_total_amount REAL;
''');
      await db.execute('''
ALTER TABLE trade_plans ADD COLUMN did_t INTEGER;
''');
    }
    // v12 修复已有v11数据库缺少字段的问题
    if (oldVersion < 12) {
      try {
        await db.execute('''
ALTER TABLE trade_plans ADD COLUMN max_buy_quantity REAL;
''');
      } catch (_) {}
      try {
        await db.execute('''
ALTER TABLE trade_plans ADD COLUMN buy_quantity REAL;
''');
      } catch (_) {}
      try {
        await db.execute('''
ALTER TABLE trade_plans ADD COLUMN buy_total_amount REAL;
''');
      } catch (_) {}
      try {
        await db.execute('''
ALTER TABLE trade_plans ADD COLUMN sell_total_amount REAL;
''');
      } catch (_) {}
      try {
        await db.execute('''
ALTER TABLE trade_plans ADD COLUMN did_t INTEGER DEFAULT 0;
''');
      } catch (_) {}
    }
  }

  Future<void> close() async {
    final db = _database;

    if (db != null) {
      await db.close();

      _database = null;
    }
  }
}

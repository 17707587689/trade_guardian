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
      version: 7,

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


        created_at TEXT NOT NULL

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
    // v2 增加交易原则表
    if (oldVersion < 2) {
      await db.execute('''

      CREATE TABLE trading_rules (

        id INTEGER PRIMARY KEY AUTOINCREMENT,

        content TEXT NOT NULL,

        sort_order INTEGER NOT NULL,

        required INTEGER NOT NULL

      )

      ''');
    }

    // v3 增加每日确认记录
    if (oldVersion < 3) {
      await db.execute('''

      CREATE TABLE daily_rule_checks (

        id INTEGER PRIMARY KEY AUTOINCREMENT,

        check_date TEXT NOT NULL UNIQUE,

        confirmed_at TEXT NOT NULL

      )

      ''');
    }

    // v4 增加计划和执行字段
    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE trade_plans
        ADD COLUMN planned_buy_date TEXT
        ''');

      await db.execute('''
        ALTER TABLE trade_plans
        ADD COLUMN planned_buy_end_date TEXT
        ''');

      await db.execute('''
        ALTER TABLE trade_plans
        ADD COLUMN executed_at TEXT
        ''');

      await db.execute('''
        ALTER TABLE trade_plans
        ADD COLUMN executed_buy_price REAL
        ''');

      await db.execute('''
        ALTER TABLE trade_plans
        ADD COLUMN executed_position_ratio REAL
        ''');

      await db.execute('''
        ALTER TABLE trade_plans
        ADD COLUMN executed_matched INTEGER DEFAULT 0
        ''');
    }

    // v5 增加收益率
    if (oldVersion < 5) {
      await db.execute('''
        ALTER TABLE trade_plans
        ADD COLUMN executed_return_rate REAL
        ''');
    }

    // v6 增加卖出信息
    if (oldVersion < 6) {
      await db.execute('''
        ALTER TABLE trade_plans
        ADD COLUMN executed_sell_price REAL
        ''');

      await db.execute('''
        ALTER TABLE trade_plans
        ADD COLUMN executed_sell_date TEXT
        ''');
    }

    // v7 预留扩展
    if (oldVersion < 7) {
      await db.execute('''
ALTER TABLE trade_plans ADD COLUMN buy_condition1 TEXT;
''');

      await db.execute('''
ALTER TABLE trade_plans ADD COLUMN buy_condition2 TEXT;
''');

      await db.execute('''
ALTER TABLE trade_plans ADD COLUMN buy_condition3 TEXT;
''');

      await db.execute('''
ALTER TABLE trade_plans ADD COLUMN sell_condition1 TEXT;
''');

      await db.execute('''
ALTER TABLE trade_plans ADD COLUMN sell_condition2 TEXT;
''');

      await db.execute('''
ALTER TABLE trade_plans ADD COLUMN sell_condition3 TEXT;
''');

      await db.execute('''
ALTER TABLE trade_plans ADD COLUMN execution_note TEXT;
''');
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

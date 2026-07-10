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
      version: 5,
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

        status TEXT NOT NULL,

        planned_buy_date TEXT,
        planned_buy_end_date TEXT,

        executed_at TEXT,
        executed_buy_price REAL,
        executed_position_ratio REAL,
        executed_matched INTEGER,

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

    if (oldVersion < 3) {
      await db.execute('''

      CREATE TABLE daily_rule_checks (

        id INTEGER PRIMARY KEY AUTOINCREMENT,

        check_date TEXT NOT NULL UNIQUE,

        confirmed_at TEXT NOT NULL

      )

    ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE trade_plans ADD COLUMN planned_buy_date TEXT;
      ''');
      await db.execute('''
        ALTER TABLE trade_plans ADD COLUMN planned_buy_end_date TEXT;
      ''');
      await db.execute('''
        ALTER TABLE trade_plans ADD COLUMN executed_at TEXT;
      ''');
      await db.execute('''
        ALTER TABLE trade_plans ADD COLUMN executed_buy_price REAL;
      ''');
      await db.execute('''
        ALTER TABLE trade_plans ADD COLUMN executed_position_ratio REAL;
      ''');
      await db.execute('''
        ALTER TABLE trade_plans ADD COLUMN executed_matched INTEGER;
      ''');
    }
    if (oldVersion < 5) {
      await db.execute('''
        ALTER TABLE trade_plans ADD COLUMN executed_return_rate REAL;
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

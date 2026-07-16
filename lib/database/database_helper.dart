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

    return await openDatabase(path, version: 1, onCreate: _createDB);
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
        buy_condition TEXT,
        sell_condition TEXT,
        execution_note TEXT,
        allow_t INTEGER DEFAULT 0,
        planned_date TEXT,
        status TEXT NOT NULL,
        executed_at TEXT,
        executed_buy_price REAL,
        executed_sell_price REAL,
        executed_sell_date TEXT,
        executed_position_ratio REAL,
        executed_matched INTEGER DEFAULT 0,
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

  Future<void> close() async {
    final db = _database;

    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

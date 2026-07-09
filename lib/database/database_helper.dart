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
      version: 2,
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
  }
}

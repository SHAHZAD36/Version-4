import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chaudhary_traders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    // Users table for PIN
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pin TEXT NOT NULL DEFAULT '1234',
        biometric_enabled INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Insert default user
    await db.insert('users', {'pin': '1234', 'biometric_enabled': 1});

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        brand TEXT,
        purchase_price REAL NOT NULL DEFAULT 0,
        sale_price REAL NOT NULL DEFAULT 0,
        opening_stock REAL NOT NULL DEFAULT 0,
        current_stock REAL NOT NULL DEFAULT 0,
        min_stock_level REAL NOT NULL DEFAULT 10
      )
    ''');

    // Customers table
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_name TEXT NOT NULL,
        owner_name TEXT,
        phone TEXT,
        area TEXT,
        opening_balance REAL NOT NULL DEFAULT 0,
        current_balance REAL NOT NULL DEFAULT 0,
        credit_limit REAL NOT NULL DEFAULT 50000
      )
    ''');

    // Sales table
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        total_amount REAL NOT NULL DEFAULT 0,
        discount REAL NOT NULL DEFAULT 0,
        net_amount REAL NOT NULL DEFAULT 0,
        payment_type TEXT NOT NULL DEFAULT 'Cash'
      )
    ''');

    // Sale items table
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity REAL NOT NULL DEFAULT 0,
        rate REAL NOT NULL DEFAULT 0,
        total REAL NOT NULL DEFAULT 0
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        date TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Cash book table
    await db.execute('''
      CREATE TABLE cash_book (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        opening_cash REAL NOT NULL DEFAULT 0,
        cash_in REAL NOT NULL DEFAULT 0,
        cash_out REAL NOT NULL DEFAULT 0,
        closing_cash REAL NOT NULL DEFAULT 0,
        notes TEXT
      )
    ''');

    // Purchases table
    await db.execute('''
      CREATE TABLE purchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supplier TEXT NOT NULL,
        date TEXT NOT NULL,
        total_amount REAL NOT NULL DEFAULT 0
      )
    ''');

    // Collections table
    await db.execute('''
      CREATE TABLE collections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        notes TEXT
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_name TEXT,
        owner_name TEXT,
        currency_symbol TEXT DEFAULT 'Rs.',
        theme_mode TEXT DEFAULT 'light',
        language TEXT DEFAULT 'ur'
      )
    ''');

    // Insert default settings
    await db.insert('settings', {
      'business_name': 'Chaudhary Traders',
      'owner_name': '',
      'currency_symbol': 'Rs.',
      'theme_mode': 'light',
      'language': 'ur'
    });
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add users table if upgrading from version 1
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          pin TEXT NOT NULL DEFAULT '1234',
          biometric_enabled INTEGER NOT NULL DEFAULT 1
        )
      ''');
      await db.insert('users', {'pin': '1234', 'biometric_enabled': 1});
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

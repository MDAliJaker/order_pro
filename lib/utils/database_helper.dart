import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('order_pro.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print('Database path: $path');

    return await openDatabase(
      path,
      version: 6, // Incremented version for staff salary management
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Helper to check if column exists
    Future<bool> columnExists(String tableName, String columnName) async {
      final result = await db.rawQuery('PRAGMA table_info($tableName)');
      return result.any((column) => column['name'] == columnName);
    }

    if (oldVersion < 2) {
      if (!await columnExists('users', 'currencyCode')) {
        await db.execute(
            'ALTER TABLE users ADD COLUMN currencyCode TEXT DEFAULT "USD"');
      }
    }
    if (oldVersion < 3) {
      if (!await columnExists('users', 'securityQuestion')) {
        await db.execute('ALTER TABLE users ADD COLUMN securityQuestion TEXT');
      }
      if (!await columnExists('users', 'securityAnswer')) {
        await db.execute('ALTER TABLE users ADD COLUMN securityAnswer TEXT');
      }
    }
    if (oldVersion < 4) {
      if (!await columnExists('users', 'binTin')) {
        await db.execute('ALTER TABLE users ADD COLUMN binTin TEXT');
      }
      if (!await columnExists('users', 'street')) {
        await db.execute('ALTER TABLE users ADD COLUMN street TEXT');
      }
      if (!await columnExists('users', 'subCity')) {
        await db.execute('ALTER TABLE users ADD COLUMN subCity TEXT');
      }
      if (!await columnExists('users', 'city')) {
        await db.execute('ALTER TABLE users ADD COLUMN city TEXT');
      }
      if (!await columnExists('users', 'state')) {
        await db.execute('ALTER TABLE users ADD COLUMN state TEXT');
      }
    }
    if (oldVersion < 5) {
      // Add role column to users table
      if (!await columnExists('users', 'role')) {
        try {
          await db.execute('ALTER TABLE users ADD COLUMN role TEXT');
          await db
              .execute('UPDATE users SET role = "Owner" WHERE role IS NULL');
        } catch (e) {
          print('Error adding role column: $e');
        }
      }

      // Create staff table if not exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS staff (
          id TEXT PRIMARY KEY,
          ownerEmail TEXT NOT NULL,
          name TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          phone TEXT NOT NULL,
          password TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (ownerEmail) REFERENCES users (email)
        )
      ''');
    }
    if (oldVersion < 6) {
      // Add salary column to staff table
      if (!await columnExists('staff', 'salary')) {
        try {
          await db.execute('ALTER TABLE staff ADD COLUMN salary REAL');
          await db
              .execute('UPDATE staff SET salary = 0.0 WHERE salary IS NULL');
        } catch (e) {
          print('Error adding salary column: $e');
        }
      }
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // User Table
    await db.execute('''
      CREATE TABLE users (
        email TEXT PRIMARY KEY,
        ownerName TEXT NOT NULL,
        businessName TEXT NOT NULL,
        phone TEXT NOT NULL,
        profileImagePath TEXT,
        password TEXT NOT NULL,
        currencyCode TEXT DEFAULT 'USD',
        securityQuestion TEXT,
        securityAnswer TEXT,
        binTin TEXT,
        street TEXT,
        subCity TEXT,
        city TEXT,
        state TEXT,
        role TEXT DEFAULT 'Owner'
      )
    ''');

    // Staff Table
    await db.execute('''
      CREATE TABLE staff (
        id TEXT PRIMARY KEY,
        ownerEmail TEXT NOT NULL,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT NOT NULL,
        password TEXT NOT NULL,
        salary REAL DEFAULT 0.0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (ownerEmail) REFERENCES users (email)
      )
    ''');

    // Customer Table
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL
      )
    ''');

    // Inventory Item Table
    await db.execute('''
      CREATE TABLE inventory_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        imagePath TEXT
      )
    ''');

    // Order Table
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        status TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        FOREIGN KEY (customerId) REFERENCES customers (id)
      )
    ''');

    // Order Item Table
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId TEXT NOT NULL,
        inventoryItemId TEXT NOT NULL,
        itemName TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (orderId) REFERENCES orders (id),
        FOREIGN KEY (inventoryItemId) REFERENCES inventory_items (id)
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

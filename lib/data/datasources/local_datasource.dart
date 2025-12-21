import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/trip_model.dart';
import '../models/expense_model.dart';

class LocalDataSource {
  static final LocalDataSource _instance = LocalDataSource._internal();
  factory LocalDataSource() => _instance;
  LocalDataSource._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'travel_diary.db');

    return await openDatabase(
      path,
      version: 3, // BUMP VERSION to trigger upgrade
      onCreate: (db, version) async {
        await _createTripsTable(db);
        await _createExpensesTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createExpensesTable(db);
        }
        // Migration for Version 3: Add isFavorite column
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE trips ADD COLUMN isFavorite INTEGER DEFAULT 0',
          );
        }
      },
    );
  }

  Future<void> _createTripsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS trips (
        id TEXT PRIMARY KEY,
        title TEXT,
        startDate TEXT,
        endDate TEXT,
        description TEXT,
        imagePath TEXT,
        isFavorite INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _createExpensesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id TEXT PRIMARY KEY,
        tripId TEXT,
        amount REAL,
        category TEXT,
        date TEXT,
        note TEXT,
        FOREIGN KEY(tripId) REFERENCES trips(id) ON DELETE CASCADE
      )
    ''');
  }

  // --- CRUD Operations (Unchanged logic, just relies on updated models) ---
  Future<void> insertTrip(TripModel trip) async {
    final db = await database;
    await db.insert(
      'trips',
      trip.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TripModel>> getTrips() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trips',
      orderBy: "startDate DESC",
    );
    return List.generate(maps.length, (i) => TripModel.fromMap(maps[i]));
  }

  Future<void> updateTrip(TripModel trip) async {
    final db = await database;
    await db.update(
      'trips',
      trip.toMap(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  Future<void> deleteTrip(String id) async {
    final db = await database;
    await db.delete('trips', where: 'id = ?', whereArgs: [id]);
  }

  // Expenses methods remain the same...
  Future<void> insertExpense(ExpenseModel expense) async {
    final db = await database;
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExpenseModel>> getExpenses(String tripId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'tripId = ?',
      whereArgs: [tripId],
      orderBy: "date DESC",
    );
    return List.generate(maps.length, (i) => ExpenseModel.fromMap(maps[i]));
  }

  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/trip_model.dart';
// import '../models/expense_model.dart';

// class LocalDataSource {
//   static final LocalDataSource _instance = LocalDataSource._internal();
//   factory LocalDataSource() => _instance;
//   LocalDataSource._internal();

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB();
//     return _database!;
//   }

//   Future<Database> _initDB() async {
//     final dbPath = await getDatabasesPath();
//     // Keeping the name simple to avoid multiple db files
//     final path = join(dbPath, 'travel_diary.db');

//     return await openDatabase(
//       path,
//       version: 2, // INCREASED VERSION TO TRIGGER UPDATES
//       onCreate: (db, version) async {
//         await _createTripsTable(db);
//         await _createExpensesTable(db);
//       },
//       onUpgrade: (db, oldVersion, newVersion) async {
//         // This runs if you already have the app installed
//         if (oldVersion < 2) {
//           await _createExpensesTable(db);
//         }
//       },
//     );
//   }

//   Future<void> _createTripsTable(Database db) async {
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS trips (
//         id TEXT PRIMARY KEY,
//         title TEXT,
//         startDate TEXT,
//         endDate TEXT,
//         description TEXT,
//         imagePath TEXT
//       )
//     ''');
//   }

//   Future<void> _createExpensesTable(Database db) async {
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS expenses (
//         id TEXT PRIMARY KEY,
//         tripId TEXT,
//         amount REAL,
//         category TEXT,
//         date TEXT,
//         note TEXT,
//         FOREIGN KEY(tripId) REFERENCES trips(id) ON DELETE CASCADE
//       )
//     ''');
//   }

//   // --- TRIP CRUD ---
//   Future<void> insertTrip(TripModel trip) async {
//     final db = await database;
//     await db.insert(
//       'trips',
//       trip.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<List<TripModel>> getTrips() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'trips',
//       orderBy: "startDate DESC",
//     );
//     return List.generate(maps.length, (i) => TripModel.fromMap(maps[i]));
//   }

//   Future<void> updateTrip(TripModel trip) async {
//     final db = await database;
//     await db.update(
//       'trips',
//       trip.toMap(),
//       where: 'id = ?',
//       whereArgs: [trip.id],
//     );
//   }

//   Future<void> deleteTrip(String id) async {
//     final db = await database;
//     await db.delete('trips', where: 'id = ?', whereArgs: [id]);
//   }

//   // --- EXPENSE CRUD ---
//   Future<void> insertExpense(ExpenseModel expense) async {
//     final db = await database;
//     await db.insert(
//       'expenses',
//       expense.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//     print("DEBUG: Expense added: ${expense.amount} to trip ${expense.tripId}");
//   }

//   Future<List<ExpenseModel>> getExpenses(String tripId) async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'expenses',
//       where: 'tripId = ?',
//       whereArgs: [tripId],
//       orderBy: "date DESC",
//     );
//     print("DEBUG: Loaded ${maps.length} expenses for trip $tripId");
//     return List.generate(maps.length, (i) => ExpenseModel.fromMap(maps[i]));
//   }

//   Future<void> deleteExpense(String id) async {
//     final db = await database;
//     await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
//   }
// }

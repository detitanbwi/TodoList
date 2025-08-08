import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = await getDatabasesPath();
    path = '$path/activities.db';
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> resetDatabase() async {
    String path = await getDatabasesPath();
    path = '$path/activities.db';
    await deleteDatabase(path);
    _database = null; // Clear the cached database instance
    await database; // Reinitialize the database
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activities(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT NULL,
        done INTEGER DEFAULT 0
      )
    ''');
  }

  Future<int> insertActivity(Map<String, dynamic> activity) async {
    Database db = await database;
    return await db.insert('activities', activity);
  }

  Future<List<Map<String, dynamic>>> getActivities() async { // Changed return type to be mutable
    Database db = await database;
    return (await db.query('activities')).toList(); // Ensure the list is mutable
  }

  Future<int> updateActivity(int id, int done) async {
    Database db = await database;
    return await db.update(
      'activities',
      {'done': done},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteActivity(int id) async {
    Database db = await database;
    return await db.delete(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

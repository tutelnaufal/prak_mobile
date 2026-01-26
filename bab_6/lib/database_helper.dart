import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Soal 1: Inisialisasi Database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'note.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        // Soal 1: Membuat Tabel
        return db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            created_at TEXT
          )
        ''');
      },
    );
  }

  // Soal 2: Insert Data
  Future<int> insertNote(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('notes', row);
  }

  // Soal 3: Menampilkan Data
  Future<List<Map<String, dynamic>>> queryAllNotes() async {
    Database db = await database;
    return await db.query('notes', orderBy: 'id DESC');
  }

  // Soal 4: Update Data
  Future<int> updateNote(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('notes', row, where: 'id = ?', whereArgs: [id]);
  }

  // Soal 5: Delete Data
  Future<int> deleteNote(int id) async {
    Database db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
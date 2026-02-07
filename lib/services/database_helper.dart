import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:skin_cancer_detector/core/models/scan_history_item.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'history.db');

    return openDatabase(
      path,
      version: 2, // ✅ subimos versión
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // ✅ sencillo: recrear (borra datos antiguos)
          await db.execute('DROP TABLE IF EXISTS history');
          await _onCreate(db, newVersion);
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imageBytes BLOB NOT NULL,
        date TEXT NOT NULL,
        diagnosisType TEXT NOT NULL,
        recognition TEXT NOT NULL,
        recommendation TEXT NOT NULL,
        diagnosisDescription TEXT NOT NULL,
        detailsJson TEXT NOT NULL
      )
    ''');
  }

  Future<List<ScanHistoryItem>> getScans() async {
    final db = await instance.database;
    final scans = await db.query('history', orderBy: 'id DESC');
    return scans.isNotEmpty
        ? scans.map((c) => ScanHistoryItem.fromMap(c)).toList()
        : [];
  }

  Future<int> addScan(ScanHistoryItem scan) async {
    final db = await instance.database;
    return db.insert('history', scan.toMap());
  }

  Future<int> deleteScan(int id) async {
    final db = await instance.database;
    return db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearHistory() async {
    final db = await instance.database;
    await db.delete('history');
  }
}

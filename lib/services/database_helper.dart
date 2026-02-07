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
      version: 3,
      onCreate: (db, _) async => _create(db),
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 3) {
          // ✅ migración simple: se pierde historial anterior
          await db.execute('DROP TABLE IF EXISTS history');
          await _create(db);
        }
      },
    );
  }

  Future<void> _create(Database db) async {
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        thumbnailBytes BLOB NOT NULL,
        imagePath TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        bodyPart TEXT NOT NULL,
        label TEXT NOT NULL,
        confidence REAL NOT NULL,
        recommendation TEXT NOT NULL,
        diagnosis TEXT NOT NULL,
        detailsJson TEXT NOT NULL
      )
    ''');
  }

  Future<List<ScanHistoryItem>> getScans({String? bodyPart}) async {
    final db = await instance.database;

    final where = (bodyPart != null && bodyPart != 'Todo') ? 'bodyPart = ?' : null;
    final args = (where != null) ? [bodyPart] : null;

    final rows = await db.query('history', where: where, whereArgs: args, orderBy: 'id DESC');
    return rows.map((e) => ScanHistoryItem.fromMap(e)).toList();
  }

  Future<int> addScan(ScanHistoryItem scan) async {
    final db = await instance.database;
    return db.insert('history', scan.toMap());
  }

  Future<void> clearHistory() async {
    final db = await instance.database;
    await db.delete('history');
    print("Historial de SQLite borrado.");
  }

  Future<int> deleteScan(int id) async {
    final db = await instance.database;
    return db.delete('history', where: 'id = ?', whereArgs: [id]);
  }
}

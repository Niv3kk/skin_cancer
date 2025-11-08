// lib/services/database_helper.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:skin_cancer_detector/core/models/scan_history_item.dart'; // <-- Importa el modelo

class DatabaseHelper {
  // Singleton (una sola instancia para toda la app)
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  // Inicializa la base de datos
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'history.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Crea la tabla cuando la DB se crea por primera vez
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT NOT NULL,
        date TEXT NOT NULL,
        recognition TEXT NOT NULL,
        diagnosisType TEXT NOT NULL,
        diagnosisDescription TEXT NOT NULL
      )
    ''');
  }

  // --- OPERACIONES CRUD ---

  // Obtener todos los escaneos
  Future<List<ScanHistoryItem>> getScans() async {
    Database db = await instance.database;
    var scans = await db.query('history', orderBy: 'id DESC');
    List<ScanHistoryItem> scanList = scans.isNotEmpty
        ? scans.map((c) => ScanHistoryItem.fromMap(c)).toList()
        : [];
    return scanList;
  }

  // Añadir un nuevo escaneo
  Future<int> addScan(ScanHistoryItem scan) async {
    Database db = await instance.database;
    return await db.insert('history', scan.toMap());
  }

  // Eliminar un escaneo
  Future<int> deleteScan(int id) async {
    Database db = await instance.database;
    return await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  // --- TU FUNCIÓN CLAVE: BORRAR TODO ---
  Future<void> clearHistory() async {
    Database db = await instance.database;
    // Esto borra todas las filas de la tabla 'history'
    await db.delete('history');
    print("Historial de SQLite borrado.");
  }
}
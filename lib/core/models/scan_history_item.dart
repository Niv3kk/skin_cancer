// lib/models/scan_history_item.dart

class ScanHistoryItem {
  final int? id; // <-- ID de la base de datos (autoincremental)
  final String imagePath;
  final String date;
  final String recognition;
  final String diagnosisType;
  final String diagnosisDescription;

  ScanHistoryItem({
    this.id, // <-- ID es opcional
    required this.imagePath,
    required this.date,
    required this.recognition,
    required this.diagnosisType,
    required this.diagnosisDescription,
  });

  // Convierte un objeto ScanHistoryItem a un Map (para insertar en DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'date': date,
      'recognition': recognition,
      'diagnosisType': diagnosisType,
      'diagnosisDescription': diagnosisDescription,
    };
  }

  // Convierte un Map (de la DB) a un objeto ScanHistoryItem
  factory ScanHistoryItem.fromMap(Map<String, dynamic> map) {
    return ScanHistoryItem(
      id: map['id'] as int?,
      imagePath: map['imagePath'] as String,
      date: map['date'] as String,
      recognition: map['recognition'] as String,
      diagnosisType: map['diagnosisType'] as String,
      diagnosisDescription: map['diagnosisDescription'] as String,
    );
  }
}
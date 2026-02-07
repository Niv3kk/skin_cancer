import 'dart:typed_data';
import 'dart:convert';

class ScanHistoryItem {
  final int? id;

  // ✅ Guardamos la imagen como bytes (BLOB)
  final Uint8List imageBytes;

  final String date;

  // Resultado principal
  final String diagnosisType;       // MELANOMA / LUNAR / PIEL SANA
  final String recognition;         // "100%" o lo que uses

  // ✅ Textos que quieres guardar
  final String recommendation;      // ACCIÓN RECOMENDADA
  final String diagnosisDescription; // DIAGNÓSTICO

  // ✅ Detalle del análisis (labels + probs) guardado como JSON
  final String detailsJson;

  ScanHistoryItem({
    this.id,
    required this.imageBytes,
    required this.date,
    required this.diagnosisType,
    required this.recognition,
    required this.recommendation,
    required this.diagnosisDescription,
    required this.detailsJson,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageBytes': imageBytes,
      'date': date,
      'diagnosisType': diagnosisType,
      'recognition': recognition,
      'recommendation': recommendation,
      'diagnosisDescription': diagnosisDescription,
      'detailsJson': detailsJson,
    };
  }

  factory ScanHistoryItem.fromMap(Map<String, dynamic> map) {
    return ScanHistoryItem(
      id: map['id'] as int?,
      imageBytes: map['imageBytes'] as Uint8List,
      date: map['date'] as String,
      diagnosisType: map['diagnosisType'] as String,
      recognition: map['recognition'] as String,
      recommendation: map['recommendation'] as String,
      diagnosisDescription: map['diagnosisDescription'] as String,
      detailsJson: map['detailsJson'] as String,
    );
  }

  // Helpers opcionales para leer el JSON fácil
  Map<String, dynamic> get details => jsonDecode(detailsJson) as Map<String, dynamic>;
}

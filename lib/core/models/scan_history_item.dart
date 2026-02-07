import 'dart:typed_data';

class ScanHistoryItem {
  final int? id;

  // ✅ para tarjetas (liviano)
  final Uint8List thumbnailBytes;

  // ✅ para abrir detalle con calidad
  final String imagePath;

  final String createdAt; // ISO
  final String bodyPart;

  final String label;       // lunar | melanoma | piel_sana
  final double confidence;  // 0..1

  final String recommendation;
  final String diagnosis;

  // JSON: {labels:[...], probs:[...]}
  final String detailsJson;

  ScanHistoryItem({
    this.id,
    required this.thumbnailBytes,
    required this.imagePath,
    required this.createdAt,
    required this.bodyPart,
    required this.label,
    required this.confidence,
    required this.recommendation,
    required this.diagnosis,
    required this.detailsJson,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'thumbnailBytes': thumbnailBytes,
    'imagePath': imagePath,
    'createdAt': createdAt,
    'bodyPart': bodyPart,
    'label': label,
    'confidence': confidence,
    'recommendation': recommendation,
    'diagnosis': diagnosis,
    'detailsJson': detailsJson,
  };

  factory ScanHistoryItem.fromMap(Map<String, dynamic> map) => ScanHistoryItem(
    id: map['id'] as int?,
    thumbnailBytes: map['thumbnailBytes'] as Uint8List,
    imagePath: map['imagePath'] as String,
    createdAt: map['createdAt'] as String,
    bodyPart: map['bodyPart'] as String,
    label: map['label'] as String,
    confidence: (map['confidence'] as num).toDouble(),
    recommendation: map['recommendation'] as String,
    diagnosis: map['diagnosis'] as String,
    detailsJson: map['detailsJson'] as String,
  );
}

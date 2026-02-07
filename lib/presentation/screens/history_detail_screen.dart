import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:skin_cancer_detector/core/models/scan_history_item.dart';
import 'package:skin_cancer_detector/services/history_pdf_exporter.dart';

class HistoryDetailScreen extends StatelessWidget {
  final ScanHistoryItem item;

  const HistoryDetailScreen({
    super.key,
    required this.item,
  });

  List<Map<String, dynamic>> _decodeDetails(String jsonStr) {
    try {
      final obj = jsonDecode(jsonStr) as Map<String, dynamic>;
      final labels = (obj['labels'] as List).map((e) => e.toString()).toList();
      final probs = (obj['probs'] as List).map((e) => (e as num).toDouble()).toList();

      final out = <Map<String, dynamic>>[];
      for (int i = 0; i < labels.length && i < probs.length; i++) {
        out.add({'label': labels[i], 'prob': probs[i]});
      }
      out.sort((a, b) => (b['prob'] as double).compareTo(a['prob'] as double));
      return out;
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _decodeDetails(item.detailsJson);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalle del análisis'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Exportar PDF',
            icon: const Icon(Icons.picture_as_pdf),
            color: Colors.red, // ✅ rojo PDF
            onPressed: () async {
              await HistoryPdfExporter.exportSingleAndShare(item);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================= IMAGEN =================
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black87, width: 2),
              ),
              child: ClipOval(
                child: item.thumbnailBytes.isNotEmpty
                    ? Image.memory(
                  item.thumbnailBytes,
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.image_not_supported, size: 60),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ================= RESULTADO =================
          Center(
            child: Text(
              item.label.toUpperCase(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: item.label == 'melanoma' ? Colors.red : Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Center(
            child: Text(
              'Nivel de identificación: ${(item.confidence * 100).toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),

          const SizedBox(height: 16),

          _section(
            title: 'PARTE DEL CUERPO',
            child: Text(item.bodyPart),
          ),

          _section(
            title: 'ACCIÓN RECOMENDADA',
            child: Text(item.recommendation),
          ),

          _section(
            title: 'DIAGNÓSTICO',
            child: Text(item.diagnosis),
          ),

          if (details.isNotEmpty)
            _section(
              title: 'DETALLE DEL ANÁLISIS',
              child: Column(
                children: details.map((d) {
                  final lbl = d['label'] as String;
                  final prob = (d['prob'] as double) * 100;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(child: Text(lbl)),
                        Text('${prob.toStringAsFixed(2)}%'),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 20),

          const Text(
            'Nota: Esto no es un diagnóstico médico. Consulte a un dermatólogo.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

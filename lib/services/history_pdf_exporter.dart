// lib/services/history_pdf_exporter.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:skin_cancer_detector/core/models/scan_history_item.dart';

class HistoryPdfExporter {
  // ================================
  // ✅ PDF DE TODO EL HISTORIAL
  // ================================
  static Future<void> exportAndShare(List<ScanHistoryItem> items) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          _header(title: 'Historial de análisis dermatológicos'),
          pw.SizedBox(height: 12),
          ...items.map((i) => _scanCard(i)).toList(),
        ],
      ),
    );

    final bytes = await pdf.save();

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'historial_analisis_medico.pdf',
    );
  }

  // ================================
  // ✅ PDF INDIVIDUAL (DESDE DETAIL)
  // ================================
  static Future<void> exportSingleAndShare(ScanHistoryItem item) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _header(title: 'Reporte médico - Análisis individual'),
              pw.SizedBox(height: 14),

              // ✅ FOTO (thumbnail) si existe
              _thumbnailBlock(item),

              pw.SizedBox(height: 14),

              _kv('Fecha', item.createdAt),
              _kv('Parte del cuerpo', item.bodyPart),

              pw.SizedBox(height: 10),

              _diagnosisBanner(item.label),

              pw.SizedBox(height: 10),

              _kv('Confianza', '${(item.confidence * 100).toStringAsFixed(2)}%'),

              pw.SizedBox(height: 12),

              _sectionTitle('Acción recomendada'),
              pw.Text(item.recommendation, style: const pw.TextStyle(fontSize: 11)),

              pw.SizedBox(height: 12),

              _sectionTitle('Diagnóstico'),
              pw.Text(item.diagnosis, style: const pw.TextStyle(fontSize: 11)),

              pw.SizedBox(height: 12),

              _sectionTitle('Detalle del análisis'),
              _detailsTable(item.detailsJson),

              pw.Spacer(),

              pw.Divider(),
              pw.Text(
                'Nota: Esto no es un diagnóstico médico definitivo. Consulte a un dermatólogo.',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'reporte_analisis_${_safeFileDate(item.createdAt)}.pdf',
    );
  }

  // ================================
  // UI PDF Helpers
  // ================================

  static pw.Widget _header({required String title}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SCANNERMEDIC',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green800,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _scanCard(ScanHistoryItem item) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Fecha: ${item.createdAt}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          pw.SizedBox(height: 6),
          pw.Text('Parte del cuerpo: ${item.bodyPart}', style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 6),
          pw.Text(
            'Resultado: ${item.label.toUpperCase()}',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: item.label == 'melanoma' ? PdfColors.red : PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text('Confianza: ${(item.confidence * 100).toStringAsFixed(2)}%', style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  static pw.Widget _kv(String k, String v) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 110,
          child: pw.Text(
            '$k:',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(child: pw.Text(v, style: const pw.TextStyle(fontSize: 11))),
      ],
    );
  }

  static pw.Widget _sectionTitle(String t) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Text(
        t.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _diagnosisBanner(String label) {
    final isBad = label.toLowerCase() == 'melanoma';
    final bg = isBad ? PdfColors.red50 : PdfColors.green50;
    final fg = isBad ? PdfColors.red : PdfColors.green800;

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: isBad ? PdfColors.red200 : PdfColors.green200),
      ),
      child: pw.Text(
        label.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  static pw.Widget _detailsTable(String jsonStr) {
    final rows = _decodeDetails(jsonStr);

    if (rows.isEmpty) {
      return pw.Text('Sin detalles disponibles.', style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700));
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('Clase', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('Probabilidad', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
            ),
          ],
        ),
        ...rows.map((r) {
          final label = r['label'] as String;
          final p = (r['prob'] as double) * 100;
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text('${p.toStringAsFixed(2)}%', style: const pw.TextStyle(fontSize: 11)),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _thumbnailBlock(ScanHistoryItem item) {
    // Tu modelo nuevo guarda thumbnailBytes (Uint8List) y NO imageBytes
    // Si viene vacío, no mostramos imagen.
    if (item.thumbnailBytes.isEmpty) {
      return pw.Text('Imagen no disponible.', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700));
    }

    final memImg = pw.MemoryImage(item.thumbnailBytes);

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 110,
            height: 110,
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(10),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.ClipRRect(
              horizontalRadius: 10,
              verticalRadius: 10,
              child: pw.Image(memImg, fit: pw.BoxFit.cover),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Imagen analizada', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.SizedBox(height: 6),
                pw.Text('Vista previa comprimida (thumbnail).', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static List<Map<String, dynamic>> _decodeDetails(String jsonStr) {
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

  static String _safeFileDate(String iso) {
    // "2026-02-06T01:23:45.000Z" -> "2026-02-06_01-23"
    try {
      final dt = DateTime.parse(iso).toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${dt.year}-${two(dt.month)}-${two(dt.day)}_${two(dt.hour)}-${two(dt.minute)}';
    } catch (_) {
      return 'fecha';
    }
  }
}

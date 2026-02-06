import 'dart:io';
import 'package:flutter/material.dart';
import 'package:skin_cancer_detector/services/tflite_classifier.dart';

const Color kPrimaryColor = Color(0xFF11E9C4);

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final ClassificationResult result;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.result,
  });

  String _prettyLabel(String raw) {
    final v = raw.trim().toLowerCase();
    switch (v) {
      case 'lunar':
        return 'LUNAR';
      case 'melanoma':
        return 'MELANOMA';
      case 'piel_sana':
      case 'piel sana':
        return 'PIEL SANA';
      default:
        return raw.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidencePct = (result.confidence * 100).round();
    final ui = _resultToUi(result.label, result.confidence);
    final mainLabel = _prettyLabel(result.label);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Logo más compacto
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Image.asset('assets/images/splash_logo.png', height: 70),
            ),

            // Barra superior: atrás
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                  label: const Text('ATRÁS'),
                  style: TextButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ✅ HEADER COMPACTO (imagen + resultado + %)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _SmallCirclePreview(imagePath: imagePath),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mainLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Nivel de identificación',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.60),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$confidencePct%',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ✅ DETALLES con más espacio
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ACCIÓN RECOMENDADA',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(ui.recommendation, style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 14),

                        const Text(
                          'DIAGNOSTICO',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(ui.diagnosis, style: const TextStyle(fontSize: 13)),

                        const SizedBox(height: 14),

                        Text(
                          'DETALLE DEL ANÁLISIS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        ...List.generate(result.probs.length, (i) {
                          final label = i < result.labels.length ? result.labels[i] : 'clase_$i';
                          final pct = (result.probs[i] * 100).toStringAsFixed(2);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                  ),
                                ),
                                Text(
                                  '$pct%',
                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 14),
                        const Text(
                          'Nota: Esto no es un diagnóstico médico. Consulta a un dermatólogo para una evaluación profesional.',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Botones abajo (igual que antes)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('REALIZAR OTRO\nANÁLISIS', textAlign: TextAlign.center),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pendiente: guardar en historial')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('GUARDAR EN\nHISTORIAL', textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallCirclePreview extends StatelessWidget {
  final String imagePath;

  const _SmallCirclePreview({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black87, width: 1.8),
      ),
      child: ClipOval(
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ResultUi {
  final String recommendation;
  final String diagnosis;
  const _ResultUi({required this.recommendation, required this.diagnosis});
}

_ResultUi _resultToUi(String label, double confidence) {
  final confPct = confidence * 100;

  switch (label) {
    case 'melanoma':
      return _ResultUi(
        recommendation:
        'Solicitar una consulta médica con un dermatólogo para confirmar el resultado del análisis y recibir el tratamiento adecuado a tiempo.',
        diagnosis:
        'La imagen presenta signos compatibles con una posible lesión tipo melanoma. Se recomienda consultar a un dermatólogo para una evaluación profesional.',
      );

    case 'lunar':
      return _ResultUi(
        recommendation: confPct >= 80
            ? 'Monitorea el lunar y consulta a un dermatólogo si notas cambios (tamaño, forma, color, sangrado o picazón).'
            : 'El resultado no es concluyente. Intenta una foto más nítida y considera una consulta médica si tienes dudas.',
        diagnosis: 'La lesión se asemeja a un lunar. Recuerda vigilar cualquier cambio con el tiempo.',
      );

    case 'piel_sana':
      return _ResultUi(
        recommendation: confPct >= 80
            ? 'No se detectan señales relevantes. Mantén protección solar y revisiones periódicas.'
            : 'El resultado no es concluyente. Intenta otra foto con mejor iluminación.',
        diagnosis: 'La imagen es compatible con piel sana según el modelo.',
      );

    default:
      return const _ResultUi(
        recommendation: 'No se pudo determinar una recomendación con esta etiqueta.',
        diagnosis: 'Etiqueta desconocida.',
      );
  }
}

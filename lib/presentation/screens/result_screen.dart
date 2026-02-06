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

  @override
  Widget build(BuildContext context) {
    final confidencePct = (result.confidence * 100).round();

    final ui = _resultToUi(result.label, result.confidence);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 6),
              child: Image.asset('assets/images/splash_logo.png', height: 110),
            ),

            // Botón atrás estilo tu mock
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                  label: const Text('ATRÁS'),
                  style: TextButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Imagen circular
            _CirclePreview(imagePath: imagePath),

            const SizedBox(height: 16),

            Text(
              'NIVEL DE IDENTIFICACIÓN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.65),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$confidencePct%',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ACCIÓN RECOMENDADA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(ui.recommendation, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 14),

                      const Text('DIAGNÓSTICO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(ui.diagnosis, style: const TextStyle(fontSize: 12)),

                      const SizedBox(height: 14),

                      // (Opcional) mostrar probabilidades por clase
                      Text('DETALLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black.withOpacity(0.75))),
                      const SizedBox(height: 6),
                      ...List.generate(result.probs.length, (i) {
                        final label = i < result.labels.length ? result.labels[i] : 'clase_$i';
                        final pct = (result.probs[i] * 100).toStringAsFixed(2);
                        return Text('- $label: $pct%', style: const TextStyle(fontSize: 12, color: Colors.black54));
                      }),

                      const SizedBox(height: 16),
                      const Text(
                        'Nota: Esto no es un diagnóstico médico. Consulta a un dermatólogo para una evaluación profesional.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // vuelve a escáner (o al flujo que prefieras)
                      },
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
                        // TODO: Guardar en historial (DB/Firestore)
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

class _CirclePreview extends StatelessWidget {
  final String imagePath;

  const _CirclePreview({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 230,
        height: 230,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black87, width: 2),
        ),
        child: ClipOval(
          child: Image.file(File(imagePath), fit: BoxFit.cover),
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

/// Mapea tus clases ("lunar", "melanoma", "piel_sana") a textos de UI
_ResultUi _resultToUi(String label, double confidence) {
  // Puedes definir umbrales si quieres:
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
        recommendation:
        confPct >= 80
            ? 'Monitorea el lunar y consulta a un dermatólogo si notas cambios (tamaño, forma, color, sangrado o picazón).'
            : 'El resultado no es concluyente. Intenta una foto más nítida y considera una consulta médica si tienes dudas.',
        diagnosis:
        'La lesión se asemeja a un lunar. Recuerda vigilar cualquier cambio con el tiempo.',
      );

    case 'piel_sana':
      return _ResultUi(
        recommendation:
        confPct >= 80
            ? 'No se detectan señales relevantes. Mantén protección solar y revisiones periódicas.'
            : 'El resultado no es concluyente. Intenta otra foto con mejor iluminación.',
        diagnosis:
        'La imagen es compatible con piel sana según el modelo.',
      );

    default:
      return const _ResultUi(
        recommendation: 'No se pudo determinar una recomendación con esta etiqueta.',
        diagnosis: 'Etiqueta desconocida.',
      );
  }
}

// lib/presentation/screens/processing_screen.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:skin_cancer_detector/services/tflite_classifier.dart';

import 'result_screen.dart';

const Color kPrimaryColor = Color(0xFF11E9C4);

class ProcessingScreen extends StatefulWidget {
  final String imagePath;
  final String bodyPart;

  // ✅ NUEVO: síntoma seleccionado antes del escaneo
  final String symptom;

  /// ✅ El classifier viene ya cargado desde SkinScanScreen
  final TfliteClassifier classifier;

  const ProcessingScreen({
    super.key,
    required this.imagePath,
    required this.bodyPart,
    required this.symptom, // ✅ NUEVO
    required this.classifier,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  double _progress = 0.0;
  Timer? _timer;

  bool _stepData = false;
  bool _stepMatrix = false;
  bool _stepSize = false;
  bool _stepColor = false;
  bool _stepAsym = false;
  bool _stepTexture = false;
  bool _stepBorder = false;

  @override
  void initState() {
    super.initState();
    _startFakeProgress();
    _runInference();
  }

  void _startFakeProgress() {
    _timer = Timer.periodic(const Duration(milliseconds: 90), (_) {
      if (!mounted) return;

      setState(() {
        const target = 0.92;
        if (_progress < target) {
          _progress = (_progress + 0.02).clamp(0.0, target);
        }

        _stepData = _progress > 0.10;
        _stepMatrix = _progress > 0.20;
        _stepSize = _progress > 0.35;
        _stepColor = _progress > 0.50;
        _stepAsym = _progress > 0.65;
        _stepTexture = _progress > 0.78;
        _stepBorder = _progress > 0.88;
      });
    });
  }

  Future<void> _runInference() async {
    try {
      // ✅ Ya viene listo desde SkinScanScreen.
      final bytes = await File(widget.imagePath).readAsBytes();
      final result = await widget.classifier.predictFromImageBytes(bytes);

      if (!mounted) return;

      _timer?.cancel();
      setState(() {
        _progress = 1.0;
        _stepData = true;
        _stepMatrix = true;
        _stepSize = true;
        _stepColor = true;
        _stepAsym = true;
        _stepTexture = true;
        _stepBorder = true;
      });

      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            imagePath: widget.imagePath,
            result: result,
            bodyPart: widget.bodyPart,
            symptom: widget.symptom, // ✅ NUEVO: lo pasamos al ResultScreen
          ),
        ),
      );
    } catch (e) {
      _timer?.cancel();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analizando la imagen: $e')),
      );

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    // ✅ NO cierres el classifier aquí porque pertenece a SkinScanScreen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_progress * 100).round();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 10),
              child: Image.asset('assets/images/splash_logo.png', height: 110),
            ),
            _CirclePreview(imagePath: widget.imagePath),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 10,
                      backgroundColor: Colors.black.withOpacity(0.08),
                      valueColor: const AlwaysStoppedAnimation(kPrimaryColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'PROCESAMIENTO DE IMAGEN $percent%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StepRow('Compilación de datos para IA', _stepData),
                    _StepRow('Análisis de matriz de IA', _stepMatrix),
                    _StepRow('Análisis de tamaño', _stepSize),
                    _StepRow('Análisis de decoloración', _stepColor),
                    _StepRow('Análisis de asimetría', _stepAsym),
                    _StepRow('Análisis de estructura de pigmento', _stepTexture),
                    _StepRow('Análisis de estructura de bordes', _stepBorder),
                    const SizedBox(height: 10),
                    const Text(
                      'Esto no es un diagnóstico médico. Consulta a un dermatólogo ante cualquier duda.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String text;
  final bool done;

  const _StepRow(this.text, this.done);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: done ? Colors.black87 : Colors.black26,
                fontSize: 13,
              ),
            ),
          ),
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: done ? kPrimaryColor : Colors.black26,
          ),
        ],
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
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

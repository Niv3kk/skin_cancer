import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassificationResult {
  final String label;
  final double confidence; // 0..1
  final List<double> probs; // 0..1
  final List<String> labels;

  ClassificationResult({
    required this.label,
    required this.confidence,
    required this.probs,
    required this.labels,
  });
}

class TfliteClassifier {
  Interpreter? _interpreter;
  late final int _h;
  late final int _w;
  late final TensorType _inType;

  // ✅ Según tu Python:
  final List<String> _labels = const ["lunar", "melanoma", "piel_sana"];

  Future<void> load() async {
    if (_interpreter != null) return;

    final options = InterpreterOptions()..threads = 2;

    // ✅ Importante: sin "assets/"
    _interpreter = await Interpreter.fromAsset(
      'assets/models/modelo_v5.tflite',
      options: options,
    );

    final input = _interpreter!.getInputTensor(0);
    final shape = input.shape; // [1,H,W,3]
    _h = shape[1];
    _w = shape[2];
    _inType = input.type;

    final out = _interpreter!.getOutputTensor(0);
    // ignore: avoid_print
    print('TFLite input: shape=$shape type=$_inType');
    // ignore: avoid_print
    print('TFLite output: shape=${out.shape} type=${out.type}');
  }

  Future<ClassificationResult> predictFromImageBytes(Uint8List imageBytes) async {
    if (_interpreter == null) {
      throw StateError('Llama load() antes de predictFromImageBytes().');
    }

    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw Exception('No se pudo decodificar la imagen.');
    }

    final resized = img.copyResize(decoded, width: _w, height: _h);

    // ✅ Input EXACTO como Python
    final input = _buildInput(resized);

    // Output: [1, N]
    final outTensor = _interpreter!.getOutputTensor(0);
    final outShape = outTensor.shape; // ej [1,3]
    final n = outShape.reduce((a, b) => a * b);

    // ✅ Output robusto: Float32List
    final outputBuffer = Float32List(n);

    _interpreter!.run(input, outputBuffer);

    final probs = outputBuffer.map((e) => e.toDouble()).toList();

    final bestIdx = _argMax(probs);
    final conf = probs[bestIdx];
    final label = bestIdx < _labels.length ? _labels[bestIdx] : 'clase_$bestIdx';

    return ClassificationResult(
      label: label,
      confidence: conf,
      probs: probs,
      labels: _labels,
    );
  }

  /// Replica MobileNetV2 preprocess: (x/127.5) - 1.0
  dynamic _buildInput(img.Image image) {
    // OJO: getPixel devuelve Pixel con r,g,b
    if (_inType == TensorType.float32) {
      final floats = Float32List(1 * _h * _w * 3);
      int i = 0;
      for (int y = 0; y < _h; y++) {
        for (int x = 0; x < _w; x++) {
          final p = image.getPixel(x, y);
          floats[i++] = (p.r / 127.5) - 1.0;
          floats[i++] = (p.g / 127.5) - 1.0;
          floats[i++] = (p.b / 127.5) - 1.0;
        }
      }
      return floats;
    }

    // Fallback uint8 (si tu modelo fuese cuantizado)
    final bytes = Uint8List(1 * _h * _w * 3);
    int i = 0;
    for (int y = 0; y < _h; y++) {
      for (int x = 0; x < _w; x++) {
        final p = image.getPixel(x, y);
        bytes[i++] = p.r.toInt();
        bytes[i++] = p.g.toInt();
        bytes[i++] = p.b.toInt();
      }
    }
    return bytes;
  }

  int _argMax(List<double> v) {
    var bestI = 0;
    var bestV = v[0];
    for (int i = 1; i < v.length; i++) {
      if (v[i] > bestV) {
        bestV = v[i];
        bestI = i;
      }
    }
    return bestI;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}

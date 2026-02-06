import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
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

  int _h = 0;
  int _w = 0;
  TensorType _inType = TensorType.float32;
  int _numClasses = 0;

  final List<String> _labels = const ["lunar", "melanoma", "piel_sana"];

  Future<void> load() async {
    if (_interpreter != null) return;

    try {
      // ✅ Cargar bytes del asset (evita problemas de path)
      final data = await rootBundle.load('assets/models/modelo_v5.tflite');
      final bytes = data.buffer.asUint8List();
      // ignore: avoid_print
      print('✅ TFLite bytes=${bytes.length}');

      final options = InterpreterOptions()..threads = 2;

      _interpreter = Interpreter.fromBuffer(bytes, options: options);

      // ✅ MUY IMPORTANTE
      _interpreter!.allocateTensors();

      final input = _interpreter!.getInputTensor(0);
      final inShape = input.shape; // [1,H,W,3]
      _inType = input.type;

      if (inShape.length != 4 || inShape[0] != 1 || inShape[3] != 3) {
        throw StateError('Input shape inesperado: $inShape');
      }

      _h = inShape[1];
      _w = inShape[2];

      final out = _interpreter!.getOutputTensor(0);
      final outShape = out.shape; // [1,N]
      if (outShape.length != 2 || outShape[0] != 1) {
        throw StateError('Output shape inesperado: $outShape');
      }
      _numClasses = outShape[1];

      // ignore: avoid_print
      print('✅ Interpreter OK | input=$inShape $_inType | out=$outShape ${out.type}');
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error load(): $e');
      rethrow;
    }
  }

  Future<ClassificationResult> predictFromImageBytes(Uint8List imageBytes) async {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError('Modelo no cargado. Llama load() primero.');
    }

    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) throw Exception('No se pudo decodificar la imagen.');

    final oriented = img.bakeOrientation(decoded);
    final resized = img.copyResize(oriented, width: _w, height: _h);

    // ✅ Input 4D REAL: [1][H][W][3]
    final input = _buildInput4D(resized);

    // ✅ Output 2D: [1][N]
    final output = List.generate(1, (_) => List.filled(_numClasses, 0.0));

    interpreter.run(input, output);

    final probs = (output[0]).map((e) => (e as num).toDouble()).toList();

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

  /// MobileNetV2 preprocess: (x/127.5) - 1.0
  List<List<List<List<double>>>> _buildInput4D(img.Image image) {
    final input = List.generate(
      1,
          (_) => List.generate(
        _h,
            (_) => List.generate(
          _w,
              (_) => List.filled(3, 0.0),
        ),
      ),
    );

    for (int y = 0; y < _h; y++) {
      for (int x = 0; x < _w; x++) {
        final p = image.getPixel(x, y);
        input[0][y][x][0] = (p.r / 127.5) - 1.0;
        input[0][y][x][1] = (p.g / 127.5) - 1.0;
        input[0][y][x][2] = (p.b / 127.5) - 1.0;
      }
    }
    return input;
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

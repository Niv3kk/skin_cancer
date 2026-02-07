import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:skin_cancer_detector/presentation/screens/processing_screen.dart';
import 'package:skin_cancer_detector/services/tflite_classifier.dart';
const Color kPrimaryColor = Color(0xFF11E9C4);

class SkinScanScreen extends StatefulWidget {
  final String bodyPart;
  const SkinScanScreen({super.key, required this.bodyPart});

  @override
  State<SkinScanScreen> createState() => _SkinScanScreenState();
}

class _SkinScanScreenState extends State<SkinScanScreen> {
  CameraController? _cameraController;
  Future<void>? _cameraFuture;
  XFile? _selectedImage;

  bool _isBusy = false;

  // ✅ Modelo
  final TfliteClassifier _classifier = TfliteClassifier();
  bool _modelReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initModel();
  }

  Future<void> _initModel() async {
    try {
      await _classifier.load(); // ✅ SIEMPRE antes de analizar
      if (!mounted) return;
      setState(() => _modelReady = true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error cargando modelo IA: $e');
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _cameraFuture = _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error inicializando cámara: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    // OJO: NO hagas dispose del classifier si lo reutilizas entre pantallas.
    // Si quieres cerrarlo al salir totalmente de la app, hazlo en un singleton/provider.
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    if (_isBusy) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _takePicture() async {
    try {
      if (_cameraController == null) return;

      await (_cameraFuture ?? Future.value());

      if (!_cameraController!.value.isInitialized) {
        _showSnack('La cámara aún no está lista.');
        return;
      }

      if (_cameraController!.value.isTakingPicture) return;

      final image = await _cameraController!.takePicture();
      if (!mounted) return;

      setState(() => _selectedImage = image);
    } catch (e) {
      if (!mounted) return;
      _showSnack('No se pudo tomar la foto: $e');
    }
  }

  Future<void> _onScanPressed() async {
    if (_isBusy) return;

    // Si aún carga el modelo, no permitas seguir
    if (!_modelReady) {
      _showSnack('El modelo aún se está cargando. Intenta de nuevo en 2 segundos.');
      return;
    }

    if (_selectedImage == null) {
      setState(() => _isBusy = true);
      try {
        await _takePicture();
      } finally {
        if (mounted) setState(() => _isBusy = false);
      }
      return;
    }

    setState(() => _isBusy = true);
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProcessingScreen(
            imagePath: _selectedImage!.path,
            bodyPart: widget.bodyPart,
            classifier: _classifier, // ✅
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildPreview(),
                  _buildOverlayGuide(),
                  if (_isBusy) _buildBusyOverlay(),
                ],
              ),
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: _isBusy ? null : () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          const Text(
            'Escáner',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_selectedImage != null) {
      return Image.file(
        File(_selectedImage!.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder(
      future: _cameraFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_cameraController!);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildOverlayGuide() {
    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
          const Icon(Icons.add, color: Colors.white, size: 36),
        ],
      ),
    );
  }

  Widget _buildBusyOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.35),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text(
            'Preparando...',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.photo_library_outlined),
                onPressed: (_isBusy || !_modelReady) ? null : _pickFromGallery,
                tooltip: 'Cargar desde galería',
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: (_isBusy || !_modelReady) ? null : _onScanPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  !_modelReady
                      ? 'Cargando IA...'
                      : (_selectedImage == null ? 'Tomar foto' : 'Realizar escaneo'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _isBusy ? null : () => setState(() => _selectedImage = null),
                tooltip: 'Limpiar imagen',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            !_modelReady
                ? 'Cargando modelo de IA...'
                : (_selectedImage == null
                ? 'Coloca la lesión dentro del círculo y toma una foto'
                : 'Pulsa “Realizar escaneo” para analizar la imagen'),
            style: const TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

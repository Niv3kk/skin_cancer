import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:skin_cancer_detector/presentation/screens/account_screen.dart';

// Color primario de la app
const Color kPrimaryColor = Color(0xFF11E9C4);

class BodySelectionScreen extends StatefulWidget {
  final String userEmail;
  // --- CAMBIO 1: Añadimos la variable para recibir el nombre ---
  final String userName;

  // --- CAMBIO 2: Actualizamos el constructor para requerir ambos datos ---
  const BodySelectionScreen({super.key, required this.userEmail, required this.userName});

  @override
  State<BodySelectionScreen> createState() => _BodySelectionScreenState();
}

class _BodySelectionScreenState extends State<BodySelectionScreen> {
  Key _modelViewerKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: ModelViewer(
                    key: _modelViewerKey,
                    src: 'assets/models/body_model.glb',
                    alt: "Modelo 3D interactivo del cuerpo humano",
                    ar: false,
                    autoRotate: false,
                    cameraControls: true,
                    backgroundColor: Colors.grey,
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: [
          Image.asset('assets/images/splash_logo.png', height: 150),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 16),
            label: const Text('Toca una zona seleccionada para ampliar una parte específica'),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF11E9C4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                // --- CAMBIO 3: Pasamos ambos datos (nombre y email) a AccountScreen ---
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AccountScreen(userEmail: widget.userEmail, userName: widget.userName),
                  ),
                );
              },
              icon: Image.asset(
                'assets/images/cuenta_icon.png', // Corregido para usar el icono de perfil
                height: 24,
                width: 24,
              ),
              label: Text(
                widget.userName, // Mostramos el nombre del usuario
                style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _modelViewerKey = UniqueKey();
              });
              print("Vista del modelo reiniciada");
            },
            icon: const Icon(Icons.refresh, color: Colors.grey),
            label: const Text(
              'Reiniciar',
              style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _modelViewerKey = UniqueKey();
                    });
                    print("Restablecer vista");
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kPrimaryColor, width: 2),
                    foregroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Restablecer vista'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Lógica para abrir la cámara/escáner
                    print("Navegar a la cámara");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Siguiente'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
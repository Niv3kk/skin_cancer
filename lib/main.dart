import 'package:flutter/material.dart';
// --- CAMBIO 1: Importamos Firebase Core y las opciones de configuración ---
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Archivo generado por FlutterFire CLI

import 'package:skin_cancer_detector/presentation/screens/onboarding_screen.dart';


// --- CAMBIO 2: La función main ahora es async ---
void main() async {
  // --- CAMBIO 3: Aseguramos la inicialización de los bindings ---
  // Es necesario antes de llamar a Firebase.initializeApp y MobileAds.initialize
  WidgetsFlutterBinding.ensureInitialized();

  // --- CAMBIO 4: Inicializamos Firebase ---
  // Esto debe hacerse antes de cualquier otra operación de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );




  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Detector de Cáncer de Piel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.cyan, // Mantenemos tu tema
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
          textTheme: const TextTheme(
            headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black87),
            bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black54, height: 1.5),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              // Mantenemos tu estilo de botón
              backgroundColor: const Color(0xFF11E9C4), // Usando tu color kPrimaryColor
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0), // Borde más redondeado como en Login
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(fontWeight: FontWeight.bold), // Añadido para consistencia
            ),
          ),
          // Añadimos estilo para OutlinedButton para consistencia
          outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF11E9C4), // Color del texto y borde
                side: const BorderSide(color: Color(0xFF11E9C4), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // Bordes consistentes
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              )
          )
      ),
      home: const OnboardingScreen(), // Mantenemos Onboarding como pantalla inicial
    );
  }
}
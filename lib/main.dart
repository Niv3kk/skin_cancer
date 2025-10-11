import 'package:flutter/material.dart';
import 'package:skin_cancer_detector/presentation/screens/onboarding_screen.dart'; // Importamos la nueva pantalla
import 'package:google_mobile_ads/google_mobile_ads.dart';


void main() {
  // Asegúrate de que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa el SDK de anuncios móviles
  MobileAds.instance.initialize();

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
        // Define el tema principal de la app
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto', // Puedes cambiar la fuente si quieres
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black54, height: 1.5),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
      ),
      // La pantalla inicial ahora es OnboardingScreen
      home: OnboardingScreen(),
    );
  }
}

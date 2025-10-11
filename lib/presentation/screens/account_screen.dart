import 'package:flutter/material.dart';
import 'package:skin_cancer_detector/presentation/screens/login_screen.dart';

// Color primario de la app
const Color kPrimaryColor = Color(0xFF11E9C4);

class AccountScreen extends StatelessWidget {
  // --- CAMBIO 1: Añadimos la variable para recibir el nombre ---
  final String userName;
  final String userEmail;

  // --- CAMBIO 2: Actualizamos el constructor ---
  const AccountScreen({super.key, required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Column(
                children: [
                  Image.asset(
                    'assets/images/splash_logo.png',
                    height: 150,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text(
                    'MI CUENTA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 35,
                backgroundColor: kPrimaryColor.withOpacity(0.2),
                child: Text(
                  // Usamos la inicial del nombre si está disponible
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // --- CAMBIO 3: Mostramos el nombre del usuario ---
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                "Estás registrado como",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                userEmail,
                style: const TextStyle(
                  fontSize: 16,
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow("Plan actual:", "Gratis"),
                  _infoRow("Renovación de escaneo gratis:", "09-06-25"),
                  _infoRow("Num. de escaneos gratuitos:", "15"),
                  _infoRow("Escaneos realizados:", "10"),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                          (route) => false,
                    );
                  },
                  child: const Text(
                    "CERRAR SESIÓN",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


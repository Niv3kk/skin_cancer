import 'package:flutter/material.dart';

import 'package:skin_cancer_detector/presentation/screens/account_screen.dart';
import 'package:skin_cancer_detector/presentation/screens/history_screen.dart';
import 'package:skin_cancer_detector/presentation/screens/help_screen.dart';
import 'package:skin_cancer_detector/presentation/screens/dermatologists_screen.dart';
import 'package:skin_cancer_detector/presentation/screens/body_selection_screen.dart';
import 'package:skin_cancer_detector/presentation/screens/login_screen.dart';

const Color kPrimaryColor = Color(0xFF11E9C4);

enum UserRole { user, admin }

class HomeScreen extends StatefulWidget {
  final String userEmail;
  final UserRole userRole;
  final String userName;

  const HomeScreen({
    super.key,
    required this.userEmail,
    required this.userRole,
    required this.userName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _assetsToPrecache = const [
    'assets/images/splash_logo.png',
    'assets/images/historial_icon.png',
    'assets/images/cuenta_icon.png',
    'assets/images/ayuda_icon.png',
    'assets/images/dermatologia_icon.png',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (final path in _assetsToPrecache) {
        try {
          await precacheImage(AssetImage(path), context);
        } catch (_) {}
      }
    });
  }

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 150),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 2),
                      Image.asset(
                        'assets/images/splash_logo.png',
                        height: 150,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'UNA SIMPLE MANERA DE VIVIR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _ScannerButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            _fadeRoute(
                              BodySelectionScreen(
                                userEmail: widget.userEmail,
                                userName: widget.userName,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _OptionGridButton(
                            imagePath: 'assets/images/historial_icon.png',
                            label: 'Historial',
                            onPressed: () {
                              Navigator.of(context)
                                  .push(_fadeRoute(const HistoryScreen()));
                            },
                          ),
                          _OptionGridButton(
                            imagePath: 'assets/images/cuenta_icon.png',
                            label: 'Mi Cuenta',
                            onPressed: () {
                              Navigator.of(context).push(
                                _fadeRoute(
                                  AccountScreen(
                                    userEmail: widget.userEmail,
                                    userName: widget.userName,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _OptionGridButton(
                            imagePath: 'assets/images/ayuda_icon.png',
                            label: 'Ayuda',
                            onPressed: () {
                              Navigator.of(context).push(
                                _fadeRoute(
                                  HelpScreen(userRole: widget.userRole),
                                ),
                              );
                            },
                          ),
                          _OptionGridButton(
                            imagePath: 'assets/images/dermatologia_icon.png',
                            label: 'Dermatología',
                            onPressed: () {
                              Navigator.of(context).push(
                                _fadeRoute(const DermatologistsScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                      const Spacer(flex: 3),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ScannerButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ScannerButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      child: Row(
        children: [
          const Icon(Icons.camera_alt_outlined, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Iniciar Escáner',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reconoce el cáncer de piel. El escáner te permite tomar foto de la lesión cutánea y analizarla.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(230),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionGridButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onPressed;

  const _OptionGridButton({
    required this.imagePath,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 120,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: const BorderSide(color: kPrimaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 48,
              width: 48,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

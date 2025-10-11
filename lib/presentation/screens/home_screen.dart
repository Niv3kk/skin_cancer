import 'package:flutter/material.dart';
// --- CAMBIO 1: Importamos el paquete de anuncios de Google ---
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:skin_cancer_detector/presentation/screens/account_screen.dart';
import 'package:skin_cancer_detector/presentation/screens/history_screen.dart';
import 'package:skin_cancer_detector/presentation/screens/help_screen.dart';
import 'package:skin_cancer_detector/presentation/screens/dermatologists_screen.dart';
import 'package:skin_cancer_detector/presentation/screens/body_selection_screen.dart';
import 'package:skin_cancer_detector/presentation/screens/login_screen.dart';


const Color kPrimaryColor = Color(0xFF11E9C4);

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
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  int _numInterstitialLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;

  // Variable para mostrar nuestro anuncio de ejemplo
  bool _showFallbackAd = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isAdLoaded) {
      _loadInterstitialAd();
    }
  }

  void _loadInterstitialAd() {
    print("Solicitando anuncio intersticial (Intento #${_numInterstitialLoadAttempts + 1})...");
    String adUnitId = 'ca-app-pub-3940256099942544/1033173712';

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('✅ Anuncio intersticial CARGADO CORRECTAMENTE.');
          _interstitialAd = ad;
          _isAdLoaded = true;
          _numInterstitialLoadAttempts = 0;

          _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              print('Anuncio cerrado por el usuario.');
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              ad.dispose();
              print('Falló al MOSTRAR el anuncio: $error');
            },
          );

          print("Mostrando anuncio...");
          _interstitialAd?.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('❌ El anuncio intersticial falló al CARGAR: $error');
          _numInterstitialLoadAttempts += 1;
          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            print("Reintentando en 10 segundos...");
            Future.delayed(const Duration(seconds: 10), () {
              if (mounted) {
                _loadInterstitialAd();
              }
            });
          } else {
            print("Se alcanzó el número máximo de reintentos. Mostrando anuncio de respaldo.");
            if (mounted) {
              setState(() {
                _showFallbackAd = true;
              });
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
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
      body: Stack(
        children: [
          // Tu contenido principal de la pantalla
          SafeArea(
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
                              Navigator.of(context).push(_fadeRoute(
                                  BodySelectionScreen(
                                      userEmail: widget.userEmail,
                                      userName: widget.userName)));
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
                                    _fadeRoute(AccountScreen(
                                      userEmail: widget.userEmail,
                                      userName: widget.userName,
                                    )),
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
                                  Navigator.of(context).push(_fadeRoute(
                                      HelpScreen(userRole: widget.userRole)));
                                },
                              ),
                              _OptionGridButton(
                                imagePath: 'assets/images/dermatologia_icon.png',
                                label: 'Dermatología',
                                onPressed: () {
                                  Navigator.of(context).push(
                                      _fadeRoute(const DermatologistsScreen()));
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

          // Se muestra el anuncio de ejemplo si la variable es true
          if (_showFallbackAd)
            _buildFallbackAd(),
        ],
      ),
    );
  }

  // --- WIDGET MEJORADO: Anuncio de ejemplo como ventana flotante ---
  Widget _buildFallbackAd() {
    return Container(
      // Fondo oscuro semitransparente para el efecto modal
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85, // 85% del ancho
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPrimaryColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // La columna se ajusta al contenido
            children: [
              // Fila para el título y el botón de cerrar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Publicidad de Ejemplo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showFallbackAd = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Icon(Icons.campaign, color: kPrimaryColor, size: 50),
              const SizedBox(height: 16),
              const Text(
                'Este es un anuncio de respaldo para demostrar que la funcionalidad de publicidad está integrada.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tus otros widgets no cambian
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
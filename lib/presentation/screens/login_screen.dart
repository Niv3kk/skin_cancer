// lib/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Auth
import 'package:skin_cancer_detector/auth_service.dart'; // Importa nuestro servicio
import 'package:skin_cancer_detector/presentation/screens/home_screen.dart';
import 'package:skin_cancer_detector/presentation/screens/signup_screen.dart'; // Importa la pantalla de registro


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Instancia de nuestro servicio de autenticación
  final AuthService _authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // El precache de imágenes está bien, lo dejamos
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

  Route _instantRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  // --- FUNCIÓN PARA INICIAR SESIÓN CON EMAIL Y CONTRASEÑA ---
  Future<void> _signInWithEmail() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa correo y contraseña.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final User? user = await _authService.signInWithEmailPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false); // Ocultar spinner

    if (user != null) {
      // Éxito: Navegar a HomeScreen
      _handleLoginSuccess(user);
    } else {
      // Error
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correo o contraseña incorrectos.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // --- FUNCIÓN PARA INICIAR SESIÓN CON GOOGLE ---
  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final User? user = await _authService.signInWithGoogle();

    setState(() => _isLoading = false); // Ocultar spinner

    if (user != null) {
      // Éxito: Navegar a HomeScreen
      _handleLoginSuccess(user);
    } else {
      // Error o cancelación del usuario
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo iniciar sesión con Google.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // --- FUNCIÓN PARA NAVEGAR A LA PANTALLA DE REGISTRO ---
  void _navigateToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      ),
    );
  }

  // --- HELPER PARA MANEJAR EL ÉXITO Y NAVEGACIÓN ---
  Future<void> _handleLoginSuccess(User user) async {
    // Obtenemos los datos (nombre, rol) de RTDB
    final userData = await _authService.getUserData(user);

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    Navigator.of(context).pushAndRemoveUntil(
      _instantRoute(HomeScreen(
        userEmail: userData['email'],
        userRole: userData['role'],
        userName: userData['name'],
      )),
          (route) => false,
    );
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // El resto de la UI no ha sido modificada
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 60.0),
                      Image.asset('assets/images/splash_logo.png', height: 120),
                      const SizedBox(height: 30),
                      Text(
                        'Iniciar Sesión',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(
                        hintText: 'Correo Electrónico',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        hintText: 'Contraseña',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          // *** CAMBIO: Llamar a _signInWithEmail ***
                          onPressed: _isLoading ? null : _signInWithEmail,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
                          )
                              : const Text('Iniciar Sesión'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDivider(),
                      const SizedBox(height: 20),
                      // --- ESTA ES LA SECCIÓN MODIFICADA ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                              'assets/images/google_logo.png',
                              // *** CAMBIO: Llamar a _signInWithGoogle ***
                              _isLoading ? (){} : _signInWithGoogle
                          ),
                          // --- BOTÓN DE FACEBOOK Y SPACER ELIMINADOS ---
                        ],
                      ),
                      // --- FIN DE LA MODIFICACIÓN ---
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¿No tienes una cuenta?"),
                      TextButton(
                        // *** CAMBIO: Llamar a _navigateToSignUp ***
                        onPressed: _isLoading ? null : _navigateToSignUp,
                        child: Text(
                          'Regístrate',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- TU CÓDIGO DE WIDGETS (SIN CAMBIOS) ---
  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword ? !_isPasswordVisible : false,
      textInputAction:
      isPassword ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_off
                : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        )
            : null,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[400])),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('O inicia sesión con',
              style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider(color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildSocialButton(String imagePath, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(15),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Image.asset(imagePath, height: 24, width: 24),
    );
  }
}
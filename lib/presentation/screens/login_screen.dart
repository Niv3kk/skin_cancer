import 'package:flutter/material.dart';
import 'package:skin_cancer_detector/presentation/screens/home_screen.dart';

enum UserRole { user, admin }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

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

  // --- FUNCIÓN DE LOGIN ACTUALIZADA ---
  Future<void> _login() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    // Credenciales de prueba
    const userEmail = 'user@test.com';
    const adminEmail = 'admin@test.com';
    const correctPassword = 'password123';

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    UserRole? userRole;
    String? userName; // Variable para el nombre del usuario

    // Verificamos credenciales y asignamos rol Y nombre
    if (email == userEmail && password == correctPassword) {
      userRole = UserRole.user;
      userName = 'Usuario de Prueba'; // Asignamos un nombre para el usuario
    } else if (email == adminEmail && password == correctPassword) {
      userRole = UserRole.admin;
      userName = 'Administrador'; // Asignamos un nombre para el admin
    }

    Future.microtask(() {
      if (!mounted) return;

      if (userRole != null && userName != null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        Navigator.of(context).pushAndRemoveUntil(
          // --- CORRECCIÓN: Pasamos todos los datos requeridos a HomeScreen ---
          _instantRoute(HomeScreen(
            userEmail: email,
            userRole: userRole,
            userName: userName,
          )),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo o contraseña incorrectos.'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => _isLoading = false);
      }
    });
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
                          onPressed: _isLoading ? null : _login,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                              'assets/images/google_logo.png', () {}),
                          const SizedBox(width: 20),
                          _buildSocialButton(
                              'assets/images/facebook_logo.png', () {}),
                        ],
                      ),
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
                        onPressed: () {},
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

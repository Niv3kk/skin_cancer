// lib/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:skin_cancer_detector/presentation/screens/home_screen.dart'; // Importa tu enum UserRole

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // --- 1. INICIO DE SESIÓN CON GOOGLE ---
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // El usuario canceló el flujo
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Guardar/Actualizar datos del usuario en RTDB
        await _saveUserToDatabase(
          user: user,
          name: user.displayName ?? 'Usuario Google',
          email: user.email!,
          isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
        );
      }
      return user;
    } catch (e) {
      print("Error en Google Sign-In: $e");
      return null;
    }
  }

  // --- 2. REGISTRO CON EMAIL Y CONTRASEÑA ---
  Future<User?> signUpWithEmailPassword(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Actualizar el perfil de Firebase Auth con el nombre
        await user.updateDisplayName(name);
        // Recargar el usuario para obtener los datos actualizados
        await user.reload();
        user = _auth.currentUser;

        // Guardar datos del nuevo usuario en RTDB
        await _saveUserToDatabase(
          user: user!,
          name: name,
          email: email,
          isNewUser: true,
        );
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print("Error de registro: $e");
      // Aquí podrías manejar errores como 'email-already-in-use'
      return null;
    }
  }

  // --- 3. INICIO DE SESIÓN CON EMAIL Y CONTRASEÑA ---
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // No es necesario guardar en RTDB aquí, porque ya se hizo en el registro.
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Error de inicio de sesión: $e");
      // Manejar errores como 'user-not-found' o 'wrong-password'
      return null;
    }
  }

  // --- 4. FUNCIÓN INTERNA PARA GUARDAR EN REALTIME DATABASE ---
  Future<void> _saveUserToDatabase({
    required User user,
    required String name,
    required String email,
    required bool isNewUser,
  }) async {
    // La referencia al usuario en la base de datos
    DatabaseReference userRef = _database.ref('users/${user.uid}');

    // Usamos `onValue.first` para comprobar si ya existen datos
    final snapshot = await userRef.once(DatabaseEventType.value);

    // Solo creamos los datos si el usuario no existe en RTDB (o si es un nuevo login)
    // Usamos `update` en lugar de `set` para no borrar datos si ya existían (como el rol)
    if (isNewUser || !snapshot.snapshot.exists) {
      await userRef.set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'role': 'user', // Asignar rol 'user' por defecto
        'createdAt': ServerValue.timestamp, // Para saber cuándo se unió
      });
    } else {
      // Si el usuario ya existe, solo actualiza el nombre y email si es necesario
      await userRef.update({
        'name': name,
        'email': email,
      });
    }
  }

  // --- 5. OBTENER DATOS DEL USUARIO (PARA LA NAVEGACIÓN) ---
  // Esta función nos dará el rol para pasarlo al HomeScreen
  Future<Map<String, dynamic>> getUserData(User user) async {
    DatabaseReference userRef = _database.ref('users/${user.uid}');
    final snapshot = await userRef.once(DatabaseEventType.value);

    if (snapshot.snapshot.exists) {
      final data = snapshot.snapshot.value as Map;
      return {
        'name': data['name'] ?? user.displayName ?? 'Usuario',
        'email': user.email!,
        'role': (data['role'] == 'admin') ? UserRole.admin : UserRole.user,
      };
    } else {
      // Fallback por si algo falló al guardar (raro)
      return {
        'name': user.displayName ?? 'Usuario',
        'email': user.email!,
        'role': UserRole.user,
      };
    }
  }

  // --- 6. CERRAR SESIÓN ---
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
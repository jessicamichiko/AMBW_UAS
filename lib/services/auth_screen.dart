// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Mendapatkan stream perubahan status autentikasi
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  // Fungsi untuk mendaftar (Sign Up)
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Tangani berbagai jenis error autentikasi
      if (e.code == 'weak-password') {
        throw Exception('Password terlalu lemah.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Email sudah terdaftar.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Format email tidak valid.');
      }
      throw Exception(e.message ?? 'Terjadi kesalahan saat mendaftar.');
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }

  // Fungsi untuk masuk (Sign In)
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Pengguna tidak ditemukan untuk email tersebut.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Password salah.');
      } else if (e.code == 'invalid-credential') {
        throw Exception('Kombinasi email/password salah.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Format email tidak valid.');
      }
      throw Exception(e.message ?? 'Terjadi kesalahan saat masuk.');
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }

  // Fungsi untuk keluar (Sign Out)
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Terjadi kesalahan saat keluar: $e');
    }
  }
}

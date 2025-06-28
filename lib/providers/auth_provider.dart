// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_screen.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _errorMessage;

  AuthProvider() {
    _authService.user.listen((user) {
      _user = user;
      _errorMessage = null; // Reset error saat status berubah
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  Future<void> signIn(String email, String password) async {
    _errorMessage = null;
    try {
      await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', ''); // Hapus prefix 'Exception: '
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    _errorMessage = null;
    try {
      await _authService.signUpWithEmailAndPassword(email, password);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _errorMessage = null;
    try {
      await _authService.signOut();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

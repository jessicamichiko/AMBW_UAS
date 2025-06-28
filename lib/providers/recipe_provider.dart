    // lib/providers/recipe_provider.dart
    import 'package:flutter/material.dart';
    import 'package:firebase_auth/firebase_auth.dart';
    import 'package:cloud_firestore/cloud_firestore.dart'; // Ini juga harusnya sudah ditemukan
    import 'dart:async'; // FIX: Pindahkan import ini ke bagian atas
    import '../models/recipe.dart';
    import '../services/recipe_service.dart';

    class RecipeProvider with ChangeNotifier {
      final RecipeService _recipeService = RecipeService();
      List<Recipe> _recipes = [];
      bool _isLoading = true;
      String? _errorMessage;
      StreamSubscription? _recipeSubscription;

      List<Recipe> get recipes => _recipes;
      bool get isLoading => _isLoading;
      String? get errorMessage => _errorMessage;

      RecipeProvider() {
        // Mendengarkan perubahan autentikasi untuk memuat resep yang relevan
        FirebaseAuth.instance.authStateChanges().listen((user) {
          _recipeSubscription?.cancel(); // Batalkan langganan sebelumnya jika ada
          if (user != null) {
            _listenToRecipes();
          } else {
            _recipes = []; // Bersihkan resep jika tidak ada user
            _isLoading = false;
            notifyListeners();
          }
        });
      }

      void _listenToRecipes() {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();

        _recipeSubscription = _recipeService.getRecipesForUser().listen(
          (data) {
            _recipes = data;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = 'Gagal memuat resep: $error';
            _isLoading = false;
            notifyListeners();
          },
        );
      }

      Future<void> addRecipe(Recipe recipe) async {
        _errorMessage = null;
        try {
          await _recipeService.addRecipe(recipe);
        } catch (e) {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          notifyListeners();
        }
      }

      Future<void> updateRecipe(Recipe recipe) async {
        _errorMessage = null;
        try {
          await _recipeService.updateRecipe(recipe);
        } catch (e) {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          notifyListeners();
        }
      }

      Future<void> deleteRecipe(String recipeId) async {
        _errorMessage = null;
        try {
          await _recipeService.deleteRecipe(recipeId);
        } catch (e) {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          notifyListeners();
        }
      }

      void clearError() {
        _errorMessage = null;
        notifyListeners();
      }

      @override
      void dispose() {
        _recipeSubscription?.cancel();
        super.dispose();
      }
    }
    
// lib/services/recipe_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recipe.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Koleksi utama resep
  // Data pengguna harus disimpan berdasarkan UID/email pengguna yang login.
  // Dalam kasus ini, kita akan menyimpan resep di koleksi 'recipes'
  // dan setiap dokumen resep akan memiliki field 'userId' yang merujuk ke UID pengguna.
  CollectionReference get _recipesCollection => _firestore.collection('recipes');

  // Menambahkan resep baru
  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _recipesCollection.add(recipe.toJson());
    } catch (e) {
      throw Exception('Gagal menambahkan resep: $e');
    }
  }

  // Mendapatkan stream resep untuk pengguna yang sedang login
  Stream<List<Recipe>> getRecipesForUser() {
    User? user = _firebaseAuth.currentUser;
    if (user == null) {
      // Jika tidak ada user, kembalikan stream kosong
      return Stream.value([]);
    }
    return _recipesCollection
        .where('userId', isEqualTo: user.uid) // Filter resep berdasarkan UID pengguna
        .orderBy('createdAt', descending: true) // Urutkan berdasarkan waktu pembuatan terbaru
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
    });
  }

  // Memperbarui resep
  Future<void> updateRecipe(Recipe recipe) async {
    if (recipe.id == null) {
      throw Exception('Resep ID tidak boleh kosong untuk pembaruan.');
    }
    try {
      await _recipesCollection.doc(recipe.id).update(recipe.toJson());
    } catch (e) {
      throw Exception('Gagal memperbarui resep: $e');
    }
  }

  // Menghapus resep
  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _recipesCollection.doc(recipeId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus resep: $e');
    }
  }
}

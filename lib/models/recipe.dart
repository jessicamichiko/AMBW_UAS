    // lib/models/recipe.dart
    import 'package:cloud_firestore/cloud_firestore.dart'; // Pastikan import ini berhasil

    class Recipe {
      String? id; // ID resep, bisa null jika baru dibuat
      final String name;
      final String description;
      final String ingredients; // Bahan-bahan dalam satu string, dipisahkan koma atau baris baru
      final String userId; // ID pengguna yang memiliki resep ini
      final Timestamp createdAt; // Waktu pembuatan resep

      Recipe({
        this.id,
        required this.name,
        required this.description,
        required this.ingredients,
        required this.userId,
        required this.createdAt, // Inisialisasi hanya di sini
      });

      // Konversi objek Recipe menjadi Map (untuk Firestore)
      Map<String, dynamic> toJson() {
        return {
          'name': name,
          'description': description,
          'ingredients': ingredients,
          'userId': userId,
          'createdAt': createdAt,
        };
      }

      // Membuat objek Recipe dari Snapshot Firestore
      factory Recipe.fromFirestore(DocumentSnapshot doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Recipe(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          ingredients: data['ingredients'] ?? '',
          userId: data['userId'] ?? '',
          createdAt: data['createdAt'] ?? Timestamp.now(), // Menggunakan Timestamp.now() sebagai fallback
        );
      }
    }
    
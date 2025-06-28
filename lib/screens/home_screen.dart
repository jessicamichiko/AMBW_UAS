// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../models/recipe.dart';
import 'package:hive_flutter/hive_flutter.dart'; // FIX: Menambahkan import Hive Flutter
import '../utils/constants.dart'; // FIX: Menambahkan import Constants untuk Hive Box

class HomeScreen extends StatefulWidget {
  // FIX: Memastikan konstruktor memiliki parameter 'key'
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final recipeProvider = Provider.of<RecipeProvider>(context);

    // Dapatkan UID pengguna yang sedang login
    final String? userId = authProvider.user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Resep Saya'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              // GoRouter akan otomatis mengarahkan ke /login karena auth state berubah
            },
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'UID Pengguna: ${userId ?? 'Tidak ada'}', // Tampilkan UID pengguna
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (recipeProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (recipeProvider.errorMessage != null) {
                    return Center(
                      child: Text(
                        recipeProvider.errorMessage!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (recipeProvider.recipes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.kitchen, size: 80, color: Colors.grey),
                          SizedBox(height: 20),
                          Text(
                            'Belum ada resep. Yuk, tambahkan yang pertama!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.go('/add_recipe');
                            },
                            icon: Icon(Icons.add),
                            label: Text('Tambah Resep Baru'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: recipeProvider.recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipeProvider.recipes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(Icons.receipt_long, color: Colors.blue),
                            ),
                            title: Text(
                              recipe.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey.shade800,
                              ),
                            ),
                            subtitle: Text(
                              recipe.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(),
                                    Text(
                                      'Bahan-bahan:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blueGrey.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      recipe.ingredients,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Dibuat pada: ${recipe.createdAt.toDate().toLocal().toString().split(' ')[0]}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(context, recipeProvider, recipe.id!);
                                        },
                                        tooltip: 'Hapus Resep',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/add_recipe');
        },
        child: Icon(Icons.add),
        tooltip: 'Tambah Resep',
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, RecipeProvider provider, String recipeId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Hapus Resep?'),
          content: Text('Anda yakin ingin menghapus resep ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Hapus', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                // FIX: Menambahkan cek 'mounted' sebelum menggunakan dialogContext setelah async gap
                if (!dialogContext.mounted) return;

                Navigator.of(dialogContext).pop(); // Tutup dialog
                await provider.deleteRecipe(recipeId);

                // FIX: Menambahkan cek 'mounted' sebelum menggunakan context setelah async gap
                if (!context.mounted) return;

                if (provider.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(provider.errorMessage!)),
                  );
                  provider.clearError();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Resep berhasil dihapus!')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

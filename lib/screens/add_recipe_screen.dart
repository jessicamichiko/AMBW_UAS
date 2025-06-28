    // lib/screens/add_recipe_screen.dart
    import 'package:flutter/material.dart';
    import 'package:go_router/go_router.dart';
    import 'package:provider/provider.dart';
    import 'package:uuid/uuid.dart';
    import 'package:cloud_firestore/cloud_firestore.dart'; // Untuk Timestamp

    import '../models/recipe.dart';
    import '../providers/recipe_provider.dart';
    import '../providers/auth_provider.dart';

    class AddRecipeScreen extends StatefulWidget {
      // FIX: Menambahkan parameter 'key' pada konstruktor
      const AddRecipeScreen({super.key});

      @override
      State<AddRecipeScreen> createState() => _AddRecipeScreenState();
    }

    class _AddRecipeScreenState extends State<AddRecipeScreen> {
      final _formKey = GlobalKey<FormState>();
      final TextEditingController _nameController = TextEditingController();
      final TextEditingController _descriptionController = TextEditingController();
      final TextEditingController _ingredientsController = TextEditingController();
      bool _isLoading = false;

      Future<void> _saveRecipe() async {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _isLoading = true;
          });

          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

          final String? userId = authProvider.user?.uid;

          if (userId == null) {
            // FIX: Hanya satu argumen positional untuk showSnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Anda harus login untuk menambahkan resep.')),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }

          final newRecipe = Recipe(
            id: Uuid().v4(), // Generate UUID unik untuk ID resep
            name: _nameController.text,
            description: _descriptionController.text,
            ingredients: _ingredientsController.text,
            userId: userId,
            createdAt: Timestamp.now(), // Gunakan Timestamp.now() untuk waktu saat ini
          );

          await recipeProvider.addRecipe(newRecipe);

          if (recipeProvider.errorMessage != null) {
            // FIX: Hanya satu argumen positional untuk showSnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(recipeProvider.errorMessage!)),
            );
            recipeProvider.clearError();
          } else {
            // FIX: Hanya satu argumen positional untuk showSnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Resep berhasil ditambahkan!')),
            );
            context.pop(); // Kembali ke halaman sebelumnya (Home Screen)
          }
          setState(() {
            _isLoading = false;
          });
        }
      }

      @override
      void dispose() {
        _nameController.dispose();
        _descriptionController.dispose();
        _ingredientsController.dispose();
        super.dispose();
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Tambah Resep Baru'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Isi Detail Resep Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Resep',
                      hintText: 'Misal: Nasi Goreng Spesial',
                      prefixIcon: Icon(Icons.food_bank),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama resep tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi',
                      hintText: 'Misal: Resep nasi goreng praktis untuk sarapan.',
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: Icon(Icons.description),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _ingredientsController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Bahan-bahan',
                      hintText: 'Misal:\n1 piring nasi\n2 siung bawang putih\n1 telur\n... (pisahkan dengan baris baru)',
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 90.0),
                        child: Icon(Icons.list_alt),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bahan-bahan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _saveRecipe,
                          child: Text(
                            'Simpan Resep',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      }
    }
    
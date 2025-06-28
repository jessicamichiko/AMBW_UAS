// lib/screens/get_started_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Impor Hive Flutter
import '../utils/constants.dart'; // Untuk mendapatkan kunci Hive

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 120,
                color: Colors.white,
              ),
              SizedBox(height: 30),
              Text(
                'Selamat Datang di Simple Recipe Keeper!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black45,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Simpan dan kelola resep masakan favorit Anda dengan mudah.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: () async {
                  // --- PENGGUNAAN HIVE ---
                  // Dapatkan instance box Hive yang sudah dibuka di main.dart.
                  final appBox = Hive.box(Constants.appBox);
                  // Simpan nilai true ke kunci `hasSeenGetStartedKey`
                  // ini menandakan bahwa layar 'Get Started' sudah dilihat.
                  await appBox.put(Constants.hasSeenGetStartedKey, true);
                  
                  // Arahkan ke halaman login setelah menandai status di Hive.
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Mulai Sekarang!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

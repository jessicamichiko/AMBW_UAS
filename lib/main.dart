// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Directive ini sudah berada di atas

// Menggunakan alias untuk AuthProvider kustom Anda untuk menghindari ambiguitas
import 'providers/auth_provider.dart' as app_auth;
import 'providers/recipe_provider.dart';
import 'screens/get_started_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_recipe_screen.dart';
import 'utils/constants.dart'; // Untuk nama box Hive

// Konfigurasi Firebase Anda yang dihasilkan oleh `flutterfire configure`
// Pastikan file ini ada di proyek Anda setelah menjalankan `flutterfire configure`
import 'firebase_options.dart'; 

void main() async {
  // Memastikan semua binding Flutter sudah diinisialisasi sebelum menjalankan aplikasi.
  WidgetsFlutterBinding.ensureInitialized();

  // --- INISIALISASI FIREBASE ---
  // Inisialisasi Firebase menggunakan opsi yang dihasilkan oleh `flutterfire configure`.
  // Ini harus dilakukan sebelum menggunakan layanan Firebase lainnya.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- INISIALISASI HIVE ---
  // Dapatkan direktori dokumen aplikasi untuk penyimpanan data Hive.
  // Ini memastikan Hive memiliki lokasi yang valid untuk menyimpan datanya.
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  // Buka box Hive yang akan digunakan untuk menyimpan status 'Get Started'.
  // 'Constants.appBox' adalah nama box Hive yang ditentukan di 'constants.dart'.
  await Hive.openBox(Constants.appBox);

  // Menjalankan aplikasi dengan MultiProvider untuk menyediakan state management
  // bagi AuthProvider dan RecipeProvider ke seluruh widget tree.
  runApp(
  MultiProvider(
    providers: [
      // FIX: Pastikan menggunakan 'app_auth.AuthProvider()'
      ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()), // <--- Pastikan ini
      ChangeNotifierProvider(create: (_) => RecipeProvider()),
    ],
    child: MyApp(),
  ),
);
}

class MyApp extends StatefulWidget {
  // Menambahkan parameter 'key' pada konstruktor sesuai praktik terbaik Flutter.
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Deklarasi GoRouter sebagai late final karena akan diinisialisasi di initState.
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Membangun konfigurasi GoRouter saat state diinisialisasi.
    _router = _buildRouter();
  }

  // Fungsi untuk membangun dan mengkonfigurasi GoRouter.
  GoRouter _buildRouter() {
    return GoRouter(
      // Lokasi awal ketika aplikasi dimulai.
      initialLocation: '/',
      // Mendefinisikan semua rute yang tersedia dalam aplikasi.
      routes: [
        GoRoute(
          path: '/',
          // Fungsi 'redirect' akan dipanggil sebelum navigasi ke rute ini.
          // Digunakan untuk mengarahkan pengguna berdasarkan kondisi tertentu.
          redirect: (BuildContext context, GoRouterState state) async {
            // Cek status "Get Started" menggunakan Hive.
            // Jika 'hasSeenGetStartedKey' belum ada atau false, itu berarti ini pertama kali.
            final appBox = Hive.box(Constants.appBox);
            final bool hasSeenGetStarted = appBox.get(Constants.hasSeenGetStartedKey, defaultValue: false);

            if (!hasSeenGetStarted) {
              // Jika belum pernah dilihat, arahkan ke layar Get Started.
              return '/get_started';
            }

            // Cek status autentikasi Firebase.
            // Dapatkan pengguna yang saat ini login dari Firebase Auth.
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              // Jika tidak ada pengguna yang login, arahkan ke halaman login.
              return '/login';
            }
            // Jika sudah login, arahkan ke halaman utama (home).
            return '/home';
          },
        ),
        // Rute untuk layar Get Started.
        GoRoute(
          path: '/get_started',
          builder: (context, state) => GetStartedScreen(),
        ),
        // Rute untuk layar Login.
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(),
        ),
        // Rute untuk layar Register.
        GoRoute(
          path: '/register',
          builder: (context, state) => RegisterScreen(),
        ),
        // Rute untuk layar Home (utama).
        GoRoute(
          path: '/home',
          builder: (context, state) => HomeScreen(),
        ),
        // Rute untuk layar Tambah Resep.
        GoRoute(
          path: '/add_recipe',
          builder: (context, state) => AddRecipeScreen(),
        ),
      ],
      // Mendengarkan perubahan state autentikasi Firebase.
      // GoRouter akan memicu refresh navigasi setiap kali status autentikasi berubah,
      // memungkinkan redirect otomatis saat login/logout.
      refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
      // Aktifkan log diagnostik GoRouter untuk debugging.
      debugLogDiagnostics: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Simple Recipe Keeper',
      // Menggunakan routerConfig untuk konfigurasi navigasi GoRouter.
      routerConfig: _router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }
}

// Kelas pembantu untuk GoRouter agar bisa mendengarkan stream perubahan state autentikasi.
// Ini memungkinkan GoRouter untuk secara reaktif memperbarui rute berdasarkan login/logout pengguna.
class GoRouterRefreshStream extends ChangeNotifier {
  // Konstruktor yang mengambil stream (misalnya, authStateChanges dari Firebase Auth).
  GoRouterRefreshStream(Stream<dynamic> stream) {
    // Memanggil notifyListeners() segera untuk memastikan rute dievaluasi pada inisialisasi.
    notifyListeners();
    // Berlangganan ke stream dan panggil notifyListeners() setiap kali ada perubahan.
    _subscription = stream.listen(
      (dynamic _) => notifyListeners(),
    );
  }

  // Langganan ke stream, akan dibatalkan saat dispose untuk menghindari memory leak.
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    // Membatalkan langganan stream saat objek ini dibuang.
    _subscription.cancel();
    super.dispose();
  }
}

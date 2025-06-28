# Simple Recipe Keeper App

Aplikasi Flutter sederhana untuk menyimpan dan mengelola resep masakan pribadi, dilengkapi dengan autentikasi pengguna menggunakan Firebase dan penyimpanan data di Firestore.

## Penjelasan Fitur

* **Autentikasi Pengguna**:
    * Mendaftar (Sign Up) dengan email dan password.
    * Masuk (Sign In) dengan email dan password.
    * Keluar (Sign Out).
    * Validasi input email/password dan tampilkan pesan kesalahan jika gagal.
* **Penyimpanan Data Cloud (Firestore)**:
    * Menggunakan Firestore (Firebase Cloud Database).
    * Data resep disimpan dan dihubungkan dengan ID pengguna yang login (UID) untuk isolasi data per pengguna.
* **Persistensi Sesi (Hive)**:
    * Menggunakan Hive untuk menyimpan status "sudah melihat layar Get Started" secara lokal, sehingga layar ini hanya muncul sekali.
    * Firebase Authentication secara otomatis menangani persistensi sesi login pengguna, jadi Anda tidak perlu login ulang setiap kali membuka aplikasi.
* **Layar Get Started (Hanya sekali)**:
    * Halaman pengantar yang menarik yang hanya ditampilkan saat aplikasi pertama kali diinstal.
    * Setelah pengguna melihatnya sekali, aplikasi akan langsung mengarahkan pengguna ke halaman login atau home pada pembukaan berikutnya.
* **Pengelolaan Resep Pribadi**:
    * Menambahkan resep baru dengan detail seperti nama, deskripsi, dan bahan-bahan.
    * Menampilkan daftar semua resep yang telah disimpan oleh pengguna yang sedang login.
    * Fungsionalitas untuk menghapus resep yang tidak lagi diinginkan.
* **Desain Navigasi & UI**:
    * Navigasi antar halaman yang rapi dan intuitif menggunakan `go_router`.
    * Antarmuka pengguna yang sederhana namun fungsional dan mudah digunakan.

## Teknologi yang Digunakan

* **Flutter**: Framework UI
* **Firebase**:
    * **Firebase Authentication**: Untuk manajemen pengguna (daftar, masuk, keluar).
    * **Cloud Firestore**: Database NoSQL untuk menyimpan data resep di cloud.
* **Hive**: Database NoSQL lokal, digunakan untuk menyimpan status aplikasi (misalnya, apakah layar "Get Started" sudah dilihat).
* **Provider**: Untuk manajemen state aplikasi.
* **GoRouter**: Untuk manajemen rute dan navigasi antar halaman.
* **UUID**: Digunakan untuk menghasilkan ID unik untuk setiap resep yang disimpan.

## Langkah Instalasi dan Build

Ikuti langkah-langkah di bawah ini untuk menginstal dan menjalankan aplikasi di lingkungan pengembangan Anda.

### Persyaratan

* Flutter SDK terinstal (versi 3.0.0 atau lebih tinggi).
* Akun Firebase aktif.
* Firebase CLI terinstal dan terautentikasi (`firebase login`).
* Node.js dan npm terinstal (diperlukan oleh Firebase CLI).

### Langkah-langkah

1.  **Clone Repositori (Jika berlaku)**
    Jika Anda mendapatkan kode ini dari repositori GitHub/GitLab, clone terlebih dahulu:
    ```bash
    git clone [URL_REPOSITORI_ANDA]
    cd simple_recipe_keeper
    ```

2.  **Tambahkan Proyek Flutter ke Firebase**
    * Buka [Firebase Console](https://console.firebase.google.com/) dan **buat proyek baru**.
    * Di proyek Firebase Anda, **aktifkan "Authentication"** (pilih metode "Email/Password") dan **"Cloud Firestore"**.
    * Di terminal, navigasikan ke direktori root proyek Flutter Anda (tempat `pubspec.yaml` berada).
    * Jalankan perintah ini untuk mengonfigurasi Firebase secara otomatis:
        ```bash
        flutterfire configure
        ```
        Ikuti petunjuk di terminal untuk memilih proyek Firebase Anda dan platform (Android, iOS) yang ingin Anda hubungkan. Ini akan membuat `firebase_options.dart` dan file konfigurasi platform (`google-services.json`, `GoogleService-Info.plist`).

3.  **Instal Dependensi Flutter**
    ```bash
    flutter pub get
    ```

4.  **Jalankan Build Runner untuk Hive**
    Ini akan menghasilkan kode yang diperlukan oleh Hive (`.g.dart` files).
    ```bash
    flutter packages pub run build_runner build --delete-conflicting-outputs
    ```

5.  **Jalankan Aplikasi**
    ```bash
    flutter run
    ```
    Pastikan Anda memiliki emulator Android atau simulator iOS yang berjalan, atau perangkat fisik yang terhubung.

## Kredensial Dummy (untuk Pengujian Login)

Untuk tujuan pengujian, Anda bisa membuat akun baru langsung dari aplikasi menggunakan fitur "Daftar Akun Baru".

**Contoh Kredensial (Anda harus mendaftar ini terlebih dahulu melalui aplikasi):**

* **Email**: `tester@example.com`
* **Password**: `password123`

## Screenshot Aplikasi Berjalan

*(Silakan sertakan screenshot aplikasi Anda yang sedang berjalan di bawah ini sesuai dengan tahapan yang diminta)*

**1. Get Started Screen**
[Image of Get Started screen]

**2. Halaman Setelah Login (Home Screen dengan beberapa data resep)**
[Image of Home screen after login]

**3. Aplikasi Utama (Home Screen) dengan Contoh Data User Terlihat di Home Page**
[Image of Home screen showing user data]

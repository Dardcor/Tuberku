# Tuberku

Tuberku adalah aplikasi seluler inovatif yang dirancang untuk membantu dalam pemantauan, pelacakan, dan penanganan pasien Tuberkulosis (TBC). Aplikasi ini memiliki sistem peran ganda (Pasien dan Admin/Puskesmas), yang mengintegrasikan layanan geolokasi untuk pelacakan zonasi, chatbot AI interaktif (Tuberku AI) untuk edukasi, dan notifikasi real-time untuk kepatuhan pengobatan.

## 🚀 Fitur Utama

### 👤 Modul Pasien
- **Dashboard Edukatif:** Mengambil berita RSS seputar kesehatan dari Kemenkes.
- **Tuberku AI:** Chatbot cerdas yang didukung oleh **Google Gemini 1.5 Flash** untuk menjawab pertanyaan tentang TBC.
- **Fasilitas Kesehatan:** Peta interaktif berbasis **Google Maps** untuk mencari faskes terdekat yang melayani pengobatan TBC.
- **Notifikasi Obat:** Pengingat jadwal minum obat secara real-time.

### 🛡️ Modul Admin (Puskesmas / Nakes)
- **Dashboard Analitik:** Ringkasan statistik jumlah pasien, tingkat kepatuhan, dan peta sebaran (Heatmap).
- **Pelacakan (Tracing):** Sistem geolokasi untuk memantau pergerakan pasien dan mendeteksi jika pasien berada di luar zona karantina.
- **Manajemen Intervensi:** Pencatatan tindakan langsung yang diberikan kepada pasien dengan riwayat lengkap.

## 🛠️ Tech Stack & Architecture

Aplikasi ini dibangun menggunakan **Flutter** dan mematuhi prinsip Clean Architecture dengan state management berbasis **GetX**.

*   **Framework:** Flutter (Android Only, min SDK 21)
*   **State Management & Routing:** GetX (`get: ^4.6.6`)
*   **Backend & Database:** Supabase (`supabase_flutter: ^2.9.0`)
*   **Maps & Geolocation:** Google Maps Flutter, Geolocator, Geocoding
*   **Artificial Intelligence:** Google Generative AI (Gemini API)
*   **Push Notifications:** Firebase Cloud Messaging (FCM) & Supabase Realtime
*   **Local Storage:** GetStorage
*   **Networking:** Dio & Dart RSS

## 📂 Struktur Direktori (GetX Pattern)

```text
lib/
├── app/
│   ├── config/          # Konfigurasi konstanta, warna, tema, dan API keys
│   └── routes/          # Definisi nama route dan GetPages mapping
├── core/
│   ├── models/          # Data models dengan metode toJson/fromJson
│   ├── services/        # Service global (Supabase, Gemini, Location, FCM, RSS)
│   └── widgets/         # Widget reusable (Card, Button, Badge, Shimmer, dll)
├── features/
│   ├── admin/           # Modul untuk Nakes/Admin (Dashboard, Tracing, Heatmap)
│   ├── auth/            # Modul Autentikasi (Pilih Peran, Persetujuan GPS)
│   ├── patient/         # Modul Pasien (Dashboard, Artikel, Fasilitas)
│   └── tuberku_ai/      # Modul Chatbot Gemini
└── main.dart            # Entry point aplikasi
```

## ⚙️ Persyaratan Sistem & Instalasi

### 1. Persyaratan Awal
*   Flutter SDK `>= 3.11.4`
*   Android Studio dengan Android SDK (Min SDK 21)
*   Akun [Supabase](https://supabase.com/)
*   Akun [Firebase](https://firebase.google.com/)
*   Akun [Google Cloud Console](https://console.cloud.google.com/) (Untuk Maps & Gemini API)

### 2. Kloning Repositori
```bash
git clone https://github.com/username/tb-care.git
cd tb-care
flutter pub get
```

## 🔑 Panduan Konfigurasi API & Layanan

Agar aplikasi dapat berjalan dengan baik, Anda harus mengonfigurasi beberapa layanan pihak ketiga.

### A. Konfigurasi Supabase
1. Buat project baru di [Supabase](https://supabase.com/).
2. Buka file `lib/app/config/supabase_config.dart`.
3. Ganti `supabaseUrl` dan `supabaseAnonKey` dengan kredensial project Anda.
```dart
static const String supabaseUrl = 'URL_SUPABASE_ANDA';
static const String supabaseAnonKey = 'ANON_KEY_SUPABASE_ANDA';
```
4. Jalankan script SQL untuk membuat tabel-tabel yang diperlukan (Schema dapat dilihat melalui struktur model aplikasi).
5. Pastikan **Row Level Security (RLS)** diaktifkan.

### B. Konfigurasi Firebase (Untuk Push Notification)
1. Buat project Android baru di [Firebase Console](https://console.firebase.google.com/).
2. Daftarkan package name aplikasi Anda: `com.example.tb_care`.
3. Unduh file `google-services.json`.
4. Letakkan file tersebut di dalam direktori `android/app/`.

### C. Konfigurasi Google Maps API
1. Buka [Google Cloud Console](https://console.cloud.google.com/).
2. Aktifkan **Maps SDK for Android**.
3. Buat API Key baru.
4. Buka file `android/app/src/main/AndroidManifest.xml`.
5. Cari meta-data `com.google.android.geo.API_KEY` dan masukkan API Key Anda:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="MASUKKAN_API_KEY_MAPS_ANDA_DISINI"/>
```

### D. Konfigurasi Gemini AI API
1. Dapatkan API Key Gemini dari [Google AI Studio](https://aistudio.google.com/).
2. **JANGAN PERNAH** hardcode API key ini di dalam source code.
3. API key dikonfigurasi melalui `dart-define` saat melakukan build atau running aplikasi.

## 🚀 Menjalankan Aplikasi

Karena menggunakan Gemini API Key via environment variables, jalankan aplikasi menggunakan perintah berikut:

**Mode Debug/Development:**
```bash
flutter run --dart-define=GEMINI_API_KEY=api_key_gemini_anda_disini
```

**Membangun APK Release:**
```bash
flutter build apk --dart-define=GEMINI_API_KEY=api_key_gemini_anda_disini
```

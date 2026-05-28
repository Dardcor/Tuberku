class AppConstants {
  AppConstants._();

  static const String appName = 'Tuberku';
  static const String appTagline = 'Pantau & Basmi TB Bersama';
  static const String logoPath = 'assets/images/logo.svg';

  // RSS Feed
  static const String rssFeedUrl = 'https://upk.kemkes.go.id/new/rss-feed';
  static const int rssCacheDurationHours = 6;

  // Gemini
  static const String geminiModel = 'gemini-2.5-flash';
  static const String geminiSystemPrompt =
      'Kamu adalah Tuberku AI, asisten kesehatan untuk pasien Tuberkulosis '
      '(TBC) di Indonesia. Jawab pertanyaan dalam Bahasa Indonesia yang '
      'sederhana dan mudah dipahami. JANGAN gunakan format markdown seperti '
      'tanda bintang (**), pagar (#), atau list markdown. Gunakan teks polos '
      'saja dengan penomoran manual jika diperlukan. Fokus pada topik: '
      'gejala TBC, efek samping obat TBC (Rifampicin, Isoniazid, FDC), cara '
      'pencegahan penularan, etika batuk, dan informasi program DOTS. Selalu '
      'akhiri jawaban dengan mencantumkan sumber referensi dari Kemenkes RI '
      'atau WHO jika relevan. Jangan memberikan diagnosis medis.';

  // Quick Questions
  static const List<String> quickQuestions = [
    'Gejala TBC',
    'Cara pencegahan',
    'Efek samping',
    'Etika batuk',
  ];

  // Zones
  static const String zoneMerah = 'merah';
  static const String zonaKuning = 'kuning';
  static const String zonaHijau = 'hijau';

  // Facility Types
  static const String facilityApotek = 'apotek';
  static const String facilityPuskesmas = 'puskesmas';
  static const String facilityKlinik = 'klinik';

  // Roles (hanya 2: pasien dan petugas)
  static const String rolePasien = 'patient';
  static const String rolePetugas = 'petugas';

  // Storage Keys
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyRole = 'user_role';
  static const String storageKeyChatHistory = 'chat_history';
  static const String storageKeyRssCache = 'rss_cache';
  static const String storageKeyRssCacheTime = 'rss_cache_time';
}

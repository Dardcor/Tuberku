<<<<<<< HEAD
=======
<<<<<<< HEAD
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  SupabaseConfig._();

  // Membaca kredensial dari .env
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? 'https://YOUR_PROJECT.supabase.co';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY';

  // Table Names
  static const String profilesTable = 'profiles';
  static const String patientsTable = 'patients';
  static const String tracingLogsTable = 'tracing_logs';
  static const String facilitiesTable = 'facilities';
  static const String notificationsTable = 'notifications';
  static const String interventionLogsTable = 'intervention_logs';
}
=======
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  SupabaseConfig._();

  // Membaca kredensial dari .env
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY';

  // Table Names
  static const String profilesTable = 'profiles';
  static const String patientsTable = 'patients';
  static const String facilitiesTable = 'facilities';
  static const String tracingLogsTable = 'tracing_logs';
  static const String zonesTable = 'zones';
  static const String articlesTable = 'articles';

  // Storage Buckets
  static const String avatarsBucket = 'avatars';
}
<<<<<<< HEAD
=======
>>>>>>> 579452a358692d1a6d2721fd9e3b7d13a27b3b41
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f

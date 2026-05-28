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

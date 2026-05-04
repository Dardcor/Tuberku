class SupabaseConfig {
  SupabaseConfig._();

  // GANTI DENGAN KREDENSIAL SUPABASE ANDA
  static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Table Names
  static const String profilesTable = 'profiles';
  static const String patientsTable = 'patients';
  static const String tracingLogsTable = 'tracing_logs';
  static const String facilitiesTable = 'facilities';
  static const String notificationsTable = 'notifications';
  static const String interventionLogsTable = 'intervention_logs';
}

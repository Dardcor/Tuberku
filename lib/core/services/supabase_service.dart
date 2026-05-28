import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/config/supabase_config.dart';
import '../models/patient_model.dart';
import '../models/facility_model.dart';
import '../models/tracing_model.dart';
import '../models/user_model.dart';

class SupabaseService extends GetxService {
  late final SupabaseClient _client;

  SupabaseClient get client => _client;

  Future<SupabaseService> init() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
    return this;
  }

  // ─── Auth ──────────────────────────────────────────────

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ─── Profiles ──────────────────────────────────────────

  Future<UserModel?> getProfile(String userId) async {
    final data = await _client
        .from(SupabaseConfig.profilesTable)
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  Future<void> upsertProfile(UserModel user) async {
    await _client.from(SupabaseConfig.profilesTable).upsert(user.toJson());
  }

  // ─── Patients ──────────────────────────────────────────

  Future<List<PatientModel>> getPatients() async {
    final data = await _client
        .from(SupabaseConfig.patientsTable)
        .select()
        .order('created_at', ascending: false);
    return data.map((e) => PatientModel.fromJson(e)).toList();
  }

  Future<List<PatientModel>> getActivePatients() async {
    final data = await _client
        .from(SupabaseConfig.patientsTable)
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return data.map((e) => PatientModel.fromJson(e)).toList();
  }

  Future<PatientModel?> activatePatient(String code) async {
    final data = await _client
        .from(SupabaseConfig.patientsTable)
        .select()
        .eq('activation_code', code)
        .maybeSingle();
    if (data == null) return null;
    return PatientModel.fromJson(data);
  }

  Future<void> updateGpsConsent(String patientId, {required bool consent}) async {
    await _client
        .from(SupabaseConfig.patientsTable)
        .update({'gps_consent': consent}).eq('id', patientId);
  }

  Future<void> updateZone(String patientId, String zone) async {
    await _client
        .from(SupabaseConfig.patientsTable)
        .update({'zone': zone}).eq('id', patientId);
  }

  Future<int> countActivePatients() async {
    final data = await _client
        .from(SupabaseConfig.patientsTable)
        .select('id')
        .eq('is_active', true);
    return data.length;
  }

  Future<int> countPatientsByZone(String zone) async {
    final data = await _client
        .from(SupabaseConfig.patientsTable)
        .select('id')
        .eq('zone', zone)
        .eq('is_active', true);
    return data.length;
  }

  // ─── Facilities ────────────────────────────────────────

  Future<List<FacilityModel>> getFacilities() async {
    final data = await _client
        .from(SupabaseConfig.facilitiesTable)
        .select()
        .order('name');
    return data.map((e) => FacilityModel.fromJson(e)).toList();
  }

  // ─── Tracing Logs ─────────────────────────────────────

  Future<List<TracingModel>> getTracingLogs({String? patientId}) async {
    var query = _client
        .from(SupabaseConfig.tracingLogsTable)
        .select();
    if (patientId != null) {
      query = query.eq('patient_id', patientId);
    }
    final data = await query.order('visited_at', ascending: false);
    return data.map((e) => TracingModel.fromJson(e)).toList();
  }

  Future<List<TracingModel>> getRecentTracingLogs({int days = 7}) async {
    final since = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final data = await _client
        .from(SupabaseConfig.tracingLogsTable)
        .select()
        .gte('created_at', since)
        .order('created_at', ascending: false);
    return data.map((e) => TracingModel.fromJson(e)).toList();
  }

  // ─── Notifications ────────────────────────────────────

  Future<void> sendNotification({
    required String patientId,
    required String sentBy,
    required String title,
    required String message,
  }) async {
    await _client.from(SupabaseConfig.notificationsTable).insert({
      'patient_id': patientId,
      'sent_by': sentBy,
      'title': title,
      'message': message,
    });
  }

  // ─── Intervention Logs ────────────────────────────────

  Future<void> logIntervention({
    required String adminId,
    required String patientId,
    required String type,
    String? notes,
    String? zoneMarked,
  }) async {
    await _client.from(SupabaseConfig.interventionLogsTable).insert({
      'admin_id': adminId,
      'patient_id': patientId,
      'type': type,
      'notes': notes,
      'zone_marked': zoneMarked,
    });
  }

  Future<int> countInterventionLogs() async {
    final data = await _client
        .from(SupabaseConfig.interventionLogsTable)
        .select('id');
    return data.length;
  }

  // ─── Realtime ─────────────────────────────────────────

  RealtimeChannel subscribeToNotifications(
    String patientId,
    void Function(Map<String, dynamic>) onInsert,
  ) {
    return _client
        .channel('notifications:$patientId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConfig.notificationsTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'patient_id',
            value: patientId,
          ),
          callback: (payload) {
            onInsert(payload.newRecord);
          },
        )
        .subscribe();
  }

  // ─── Chat History ────────────────────────────────────
  Future<List<Map<String, dynamic>>> getChatSessions() async {
    final user = currentUser;
    if (user == null) return [];
    
    return await _client
        .from('chat_sessions')
        .select()
        .eq('profile_id', user.id)
        .order('created_at', ascending: false);
  }

  Future<String> createChatSession(String? title) async {
    final user = currentUser;
    if (user == null) throw Exception('User not logged in');
    
    final response = await _client.from('chat_sessions').insert({
      'profile_id': user.id,
      'title': title ?? 'Sesi Chat Baru',
    }).select().single();
    
    return response['id'] as String;
  }

  Future<List<Map<String, dynamic>>> getChatMessages(String sessionId) async {
    return await _client
        .from('chat_messages')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);
  }

  Future<void> saveChatMessage({
    required String sessionId,
    required String role,
    required String content,
  }) async {
    await _client.from('chat_messages').insert({
      'session_id': sessionId,
      'role': role,
      'content': content,
    });
  }
}

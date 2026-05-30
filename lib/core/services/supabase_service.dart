import 'package:flutter/material.dart';
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
    _seedSurabayaTimurData();
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
    try {
      final data = await _client
          .from(SupabaseConfig.profilesTable)
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return null;
      return UserModel.fromJson(data);
    } catch (e) {
      debugPrint('[SupabaseService] getProfile error: $e');
      return null;
    }
  }

  Future<void> upsertProfile(UserModel user) async {
    await _client.from(SupabaseConfig.profilesTable).upsert(user.toJson());
  }

  // ─── Patients ──────────────────────────────────────────

  Future<List<PatientModel>> getPatients() async {
    try {
      final data = await _client
          .from(SupabaseConfig.patientsTable)
          .select()
          .order('created_at', ascending: false);
      return data.map((e) => PatientModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('[SupabaseService] getPatients error: $e');
      return [];
    }
  }

  Future<PatientModel?> getPatientByProfileId(String profileId) async {
    try {
      final data = await _client
          .from(SupabaseConfig.patientsTable)
          .select()
          .eq('profile_id', profileId)
          .maybeSingle();
      if (data == null) return null;
      return PatientModel.fromJson(data);
    } catch (e) {
      debugPrint('[SupabaseService] getPatientByProfileId error: $e');
      return null;
    }
  }

  Future<List<PatientModel>> getActivePatients() async {
    try {
      final data = await _client
          .from(SupabaseConfig.patientsTable)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return data.map((e) => PatientModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('[SupabaseService] getActivePatients error: $e');
      return [];
    }
  }

  Future<bool> activatePatient(String code, String profileId) async {
    try {
      final bool success = await _client.rpc('activate_patient', params: {
        'p_code': code,
        'p_profile_id': profileId,
      });
      return success;
    } catch (e) {
      debugPrint('[SupabaseService] activatePatient error: $e');
      return false;
    }
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

  Future<void> updatePatient(String patientId, Map<String, dynamic> data) async {
    await _client
        .from(SupabaseConfig.patientsTable)
        .update(data)
        .eq('id', patientId);
  }

  Future<void> insertArticle(Map<String, dynamic> data) async {
    await _client
        .from(SupabaseConfig.articlesTable)
        .insert(data);
  }

  Future<List<Map<String, dynamic>>> getZones() async {
    try {
      final data = await _client
          .from(SupabaseConfig.zonesTable)
          .select()
          .order('name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('[SupabaseService] getZones error: $e');
      return [];
    }
  }

  Future<int> countActivePatients() async {
    try {
      final data = await _client
          .from(SupabaseConfig.patientsTable)
          .select('id')
          .eq('is_active', true);
      return data.length;
    } catch (e) {
      debugPrint('[SupabaseService] countActivePatients error: $e');
      return 0;
    }
  }

  Future<int> countActivePatientsForOfficer(String officerId) async {
    try {
      final profile = await getProfile(officerId);
      final facilityName = profile?.facilityName;

      if (facilityName != null && facilityName.isNotEmpty) {
        // Query active patients that either have created_by = officerId OR facility_name = officer's facilityName
        final data = await _client
            .from(SupabaseConfig.patientsTable)
            .select('id')
            .eq('is_active', true)
            .or('created_by.eq.$officerId,facility_name.eq."$facilityName"');
        return data.length;
      } else {
        final data = await _client
            .from(SupabaseConfig.patientsTable)
            .select('id')
            .eq('is_active', true)
            .eq('created_by', officerId);
        return data.length;
      }
    } catch (e) {
      debugPrint('[SupabaseService] countActivePatientsForOfficer main error: $e');
      // Simple fallback to facility name match if the OR query fails (e.g. created_by column does not exist)
      try {
        final profile = await getProfile(officerId);
        if (profile != null && profile.facilityName != null && profile.facilityName!.isNotEmpty) {
          final data = await _client
              .from(SupabaseConfig.patientsTable)
              .select('id')
              .eq('is_active', true)
              .eq('facility_name', profile.facilityName!);
          return data.length;
        }
      } catch (innerError) {
        debugPrint('[SupabaseService] countActivePatientsForOfficer fallback error: $innerError');
      }
      return 0;
    }
  }

  Future<int> countPatients() async {
    try {
      final data = await _client
          .from(SupabaseConfig.patientsTable)
          .select('id');
      return data.length;
    } catch (e) {
      debugPrint('[SupabaseService] countPatients error: $e');
      return 0;
    }
  }

  Future<int> countPatientsByZone(String zone) async {
    try {
      final data = await _client
          .from(SupabaseConfig.patientsTable)
          .select('id')
          .eq('zone', zone)
          .eq('is_active', true);
      return data.length;
    } catch (e) {
      debugPrint('[SupabaseService] countPatientsByZone error: $e');
      return 0;
    }
  }

  // ─── Facilities ────────────────────────────────────────

  Future<List<FacilityModel>> getFacilities() async {
    try {
      final data = await _client
          .from(SupabaseConfig.facilitiesTable)
          .select()
          .order('name');
      return data.map((e) => FacilityModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('[SupabaseService] getFacilities error: $e');
      return [];
    }
  }

  // ─── Tracing Logs ─────────────────────────────────────

  Future<List<TracingModel>> getTracingLogs({String? patientId}) async {
    try {
      var query = _client
          .from(SupabaseConfig.tracingLogsTable)
          .select();
      if (patientId != null) {
        query = query.eq('patient_id', patientId);
      }
      final data = await query.order('visited_at', ascending: false);
      return data.map((e) => TracingModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('[SupabaseService] getTracingLogs error: $e');
      return [];
    }
  }

  Future<List<TracingModel>> getRecentTracingLogs({int days = 7}) async {
    try {
      final since = DateTime.now().subtract(Duration(days: days)).toIso8601String();
      final data = await _client
          .from(SupabaseConfig.tracingLogsTable)
          .select()
          .gte('created_at', since)
          .order('created_at', ascending: false);
      return data.map((e) => TracingModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('[SupabaseService] getRecentTracingLogs error: $e');
      return [];
    }
  }

  // ─── Chat History ────────────────────────────────────
  Future<List<Map<String, dynamic>>> getChatSessions() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      return await _client
          .from('chat_sessions')
          .select()
          .eq('profile_id', user.id)
          .order('created_at', ascending: false);
    } catch (e) {
      debugPrint('[SupabaseService] getChatSessions error: $e');
      return [];
    }
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
    try {
      return await _client
          .from('chat_messages')
          .select()
          .eq('session_id', sessionId)
          .order('created_at', ascending: true);
    } catch (e) {
      debugPrint('[SupabaseService] getChatMessages error: $e');
      return [];
    }
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

  Future<void> _seedSurabayaTimurData() async {
    try {
      // 1. Delete Bandung facilities/zones (which do not match Surabaya Timur)
      await _client.from('facilities').delete().not('name', 'in', [
        'Puskesmas Mulyorejo',
        'Puskesmas Rungkut',
        'Puskesmas Kalirungkut',
        'Puskesmas Sukolilo',
        'Puskesmas Gunung Anyar',
        'Puskesmas Menur',
        'Puskesmas Gubeng Masjid',
        'Puskesmas Tambaksari',
        'Puskesmas Pacar Keling',
        'Puskesmas Gading'
      ]);

      await _client.from('zones').delete().not('name', 'in', [
        'Kecamatan Gubeng',
        'Kecamatan Tambaksari',
        'Kecamatan Sukolilo',
        'Kecamatan Rungkut',
        'Kecamatan Mulyorejo',
        'Kecamatan Gunung Anyar',
        'Kecamatan Tenggilis Mejoyo'
      ]);

      // 2. Insert Surabaya Timur facilities if they do not exist
      final existingFacilities = await _client.from('facilities').select('name');
      final existingFacNames = (existingFacilities as List).map((f) => f['name'] as String).toSet();

      final facilitiesToSeed = [
        {'name': 'Puskesmas Mulyorejo', 'type': 'Puskesmas', 'address': 'Jl. Mulyorejo No. 12, Surabaya', 'latitude': -7.2694, 'longitude': 112.7885},
        {'name': 'Puskesmas Rungkut', 'type': 'Puskesmas', 'address': 'Jl. Rungkut Asri Timur No. 1, Surabaya', 'latitude': -7.3223, 'longitude': 112.7758},
        {'name': 'Puskesmas Kalirungkut', 'type': 'Puskesmas', 'address': 'Jl. Rungkut Lor No. 22, Surabaya', 'latitude': -7.3200, 'longitude': 112.7810},
        {'name': 'Puskesmas Sukolilo', 'type': 'Puskesmas', 'address': 'Jl. Sukolilo No. 34, Surabaya', 'latitude': -7.2917, 'longitude': 112.7958},
        {'name': 'Puskesmas Gunung Anyar', 'type': 'Puskesmas', 'address': 'Jl. Gunung Anyar Timur No. 5, Surabaya', 'latitude': -7.3323, 'longitude': 112.7885},
        {'name': 'Puskesmas Menur', 'type': 'Puskesmas', 'address': 'Jl. Menur Pumpungan No. 1, Surabaya', 'latitude': -7.2830, 'longitude': 112.7700},
        {'name': 'Puskesmas Gubeng Masjid', 'type': 'Puskesmas', 'address': 'Jl. Gubeng Masjid No. 2, Surabaya', 'latitude': -7.2750, 'longitude': 112.7530},
        {'name': 'Puskesmas Tambaksari', 'type': 'Puskesmas', 'address': 'Jl. Tambaksari No. 12, Surabaya', 'latitude': -7.2514, 'longitude': 112.7661},
        {'name': 'Puskesmas Pacar Keling', 'type': 'Puskesmas', 'address': 'Jl. Pacar Keling No. 15, Surabaya', 'latitude': -7.2590, 'longitude': 112.7600},
        {'name': 'Puskesmas Gading', 'type': 'Puskesmas', 'address': 'Jl. Kenjeran No. 280, Surabaya', 'latitude': -7.2450, 'longitude': 112.7750},
      ];

      for (final fac in facilitiesToSeed) {
        if (!existingFacNames.contains(fac['name'])) {
          await _client.from('facilities').insert(fac);
        }
      }

      // 3. Insert Surabaya Timur zones if they do not exist
      final existingZones = await _client.from('zones').select('name');
      final existingZoneNames = (existingZones as List).map((z) => z['name'] as String).toSet();

      final zonesToSeed = [
        {'name': 'Kecamatan Gubeng', 'level': 'merah', 'case_count': 24, 'latitude': -7.2816, 'longitude': 112.7562},
        {'name': 'Kecamatan Tambaksari', 'level': 'merah', 'case_count': 31, 'latitude': -7.2514, 'longitude': 112.7661},
        {'name': 'Kecamatan Sukolilo', 'level': 'kuning', 'case_count': 15, 'latitude': -7.2917, 'longitude': 112.7958},
        {'name': 'Kecamatan Rungkut', 'level': 'kuning', 'case_count': 12, 'latitude': -7.3223, 'longitude': 112.7758},
        {'name': 'Kecamatan Mulyorejo', 'level': 'hijau', 'case_count': 5, 'latitude': -7.2694, 'longitude': 112.7885},
        {'name': 'Kecamatan Gunung Anyar', 'level': 'hijau', 'case_count': 3, 'latitude': -7.3323, 'longitude': 112.7885},
        {'name': 'Kecamatan Tenggilis Mejoyo', 'level': 'hijau', 'case_count': 2, 'latitude': -7.3204, 'longitude': 112.7621},
      ];

      for (final zone in zonesToSeed) {
        if (!existingZoneNames.contains(zone['name'])) {
          await _client.from('zones').insert(zone);
        }
      }
    } catch (e) {
      debugPrint('[SupabaseService] _seedSurabayaTimurData error: $e');
    }
  }
}

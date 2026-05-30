<<<<<<< HEAD
=======
<<<<<<< HEAD
import 'package:get/get.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/rss_service.dart';
import '../../../core/models/article_model.dart';
import '../../../core/models/user_model.dart';

class PatientDashboardController extends GetxController {
  final _supabase = Get.find<SupabaseService>();
  final _rss = Get.find<RssService>();

  final isLoading = true.obs;
  final userName = ''.obs;
  final articles = <ArticleModel>[].obs;
  final currentTabIndex = 0.obs;
  final hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      await Future.wait([
        _loadProfile(),
        _loadArticles(),
      ]);
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadProfile() async {
    final user = _supabase.currentUser;
    if (user != null) {
      final profile = await _supabase.getProfile(user.id);
      if (profile != null) {
        userName.value = profile.fullName;
      }
    }
  }

  Future<void> _loadArticles() async {
    final result = await _rss.fetchArticles();
    articles.assignAll(result);
  }

  Future<void> refresh() async {
    await _loadData();
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }
}
=======
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/rss_service.dart';
import '../../../core/models/article_model.dart';
import '../views/patient_dashboard_content.dart';
import '../views/facility_map_screen.dart';
import '../views/article_list_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../controllers/article_controller.dart';
import '../controllers/facility_map_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class PatientDashboardController extends GetxController {
  final _supabase = Get.find<SupabaseService>();
  final _rss = Get.find<RssService>();

  final isLoading = true.obs;
  final userName = ''.obs;
  final articles = <ArticleModel>[].obs;
  final currentTabIndex = 0.obs;
  final hasError = false.obs;

  late final List<Widget> pages = [
    const PatientDashboardContent(),
    const FacilityMapScreen(),
    const ArticleListScreen(),
    const ProfileScreen(),
  ];

  @override
  void onInit() {
    super.onInit();
    // Initialize required controllers
    Get.put(ProfileController());
    Get.put(ArticleController());
    Get.put(FacilityMapController());
    
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      await Future.wait([
        _loadProfile(),
        _loadArticles(),
      ]);
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadProfile() async {
    final user = _supabase.currentUser;
    if (user != null) {
      final profile = await _supabase.getProfile(user.id);
      if (profile != null) {
        userName.value = profile.fullName;
      }
    }
  }

  Future<void> _loadArticles() async {
    final result = await _rss.fetchArticles();
    articles.assignAll(result);
  }

  Future<void> refresh() async {
    await _loadData();
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }
}
<<<<<<< HEAD
=======
>>>>>>> 579452a358692d1a6d2721fd9e3b7d13a27b3b41
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f

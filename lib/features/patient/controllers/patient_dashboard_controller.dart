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

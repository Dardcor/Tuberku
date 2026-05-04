import 'package:get/get.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/rss_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SupabaseService(), permanent: true);
    Get.put(GeminiService(), permanent: true);
    Get.put(LocationService(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    Get.put(RssService(), permanent: true);
  }
}

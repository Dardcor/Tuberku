import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService extends GetxService {
  late final FirebaseMessaging _messaging;

  Future<NotificationService> init() async {
    _messaging = FirebaseMessaging.instance;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background message tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    return this;
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      Get.snackbar(
        message.notification!.title ?? 'Notifikasi',
        message.notification!.body ?? '',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Navigate based on message data if needed
    final route = message.data['route'];
    if (route != null) {
      Get.toNamed(route as String);
    }
  }
}

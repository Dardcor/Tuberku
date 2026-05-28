import 'package:get/get.dart';

class PatientNotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;

  PatientNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
  });
}

class PatientNotificationController extends GetxController {
  final notifications = <PatientNotificationModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Hardcoded patient-specific notifications
    notifications.assignAll([
      PatientNotificationModel(
        id: '1',
        title: 'Info Penting',
        message: 'Mohon periksa profil Anda untuk pembaruan status kesehatan terbaru.',
        date: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PatientNotificationModel(
        id: '2',
        title: 'Pembaruan Edukasi',
        message: 'Artikel baru tentang gizi untuk pasien TBC telah ditambahkan.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ]);
    
    isLoading.value = false;
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final notif = notifications[index];
      notifications[index] = PatientNotificationModel(
        id: notif.id,
        title: notif.title,
        message: notif.message,
        date: notif.date,
        isRead: true,
      );
    }
  }

  void markAllAsRead() {
    final updated = notifications.map((n) => PatientNotificationModel(
      id: n.id,
      title: n.title,
      message: n.message,
      date: n.date,
      isRead: true,
    )).toList();
    notifications.assignAll(updated);
  }
}

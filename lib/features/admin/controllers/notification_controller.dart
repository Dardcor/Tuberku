import 'package:get/get.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
  });
}

class NotificationController extends GetxController {
  final notifications = <NotificationModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    
    // Simulasi delay jaringan
    await Future.delayed(const Duration(seconds: 1));
    
    // Ini bisa dihubungkan ke tabel notifikasi di Supabase nantinya
    notifications.assignAll([
      NotificationModel(
        id: '1',
        title: 'Pasien Keluar Zona',
        message: 'Pasien TB-2026-1024 terdeteksi berada di luar zona karantina merah.',
        date: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        id: '2',
        title: 'Laporan Tracing Baru',
        message: 'Ada 3 kontak erat baru yang ditambahkan di wilayah Gubeng.',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      NotificationModel(
        id: '3',
        title: 'Pasien Sembuh',
        message: 'Pasien TB-2025-4512 telah menyelesaikan program pengobatan.',
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
      notifications[index] = NotificationModel(
        id: notif.id,
        title: notif.title,
        message: notif.message,
        date: notif.date,
        isRead: true,
      );
    }
  }

  void markAllAsRead() {
    final updated = notifications.map((n) => NotificationModel(
      id: n.id,
      title: n.title,
      message: n.message,
      date: n.date,
      isRead: true,
    )).toList();
    notifications.assignAll(updated);
  }
}

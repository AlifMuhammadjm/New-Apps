import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Service untuk mengelola notifikasi
class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Inisialisasi layanan notifikasi
  Future<void> initialize() async {
    try {
      // Konfigurasi untuk Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Konfigurasi untuk iOS
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Konfigurasi untuk semua platform
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Inisialisasi plugin notifikasi
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      debugPrint('Notification Service initialized');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  /// Handler ketika notifikasi di-tap
  void _onNotificationTap(NotificationResponse notificationResponse) {
    // Proses notifikasi yang di-tap, misalnya navigasi ke layar tertentu
    debugPrint('Notification tapped: ${notificationResponse.payload}');
  }

  /// Menampilkan notifikasi lokal
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'freelanceguard_channel',
      'FreelanceGuard Notifications',
      channelDescription: 'Notification channel for FreelanceGuard app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // ID unik untuk notifikasi
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Berlangganan ke topik notifikasi (simulasi - dalam implementasi sebenarnya menggunakan Firebase)
  Future<void> subscribeToTopic(String topic) async {
    debugPrint('Subscribed to topic: $topic');
    // Simulasi berhasil, dalam implementasi sebenarnya menggunakan Firebase Messaging
    // await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  /// Berhenti berlangganan dari topik notifikasi (simulasi)
  Future<void> unsubscribeFromTopic(String topic) async {
    debugPrint('Unsubscribed from topic: $topic');
    // Simulasi berhasil, dalam implementasi sebenarnya menggunakan Firebase Messaging
    // await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  /// Tampilkan toast message
  void showFlutterToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: isError ? Colors.red : Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Menampilkan snackbar
  void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.black87,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  /// Menampilkan dialog konfirmasi
  Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Menampilkan dialog loading
  void showLoadingDialog(BuildContext context, {String message = 'Memuat...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  /// Tutup dialog (berguna untuk dialog loading)
  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Menampilkan notifikasi banner di atas layar
  void showBanner(
    BuildContext context, {
    required String message,
    required IconData icon,
    Color backgroundColor = Colors.blue,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          actions: [
            TextButton(
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
              child: const Text(
                'TUTUP',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

    // Auto-hide banner after duration
    Future.delayed(duration, () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      }
    });
  }

  // Mendapatkan token FCM - versi dummy
  Future<String?> getToken() async {
    debugPrint('FCM Token request (mode dummy): token-123456');
    return 'dummy-fcm-token-123456';
  }
} 
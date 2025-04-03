import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Konfigurasi default untuk Firebase untuk aplikasi Freelancer OS Demo
///
/// Catatan: Untuk produksi, Anda harus mengisi dengan konfigurasi Firebase Anda sendiri
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Konfigurasi untuk Firebase Web
      return const FirebaseOptions(
        apiKey: 'YOUR_WEB_API_KEY',
        appId: 'YOUR_WEB_APP_ID',
        messagingSenderId: 'YOUR_WEB_MESSAGING_SENDER_ID',
        projectId: 'YOUR_WEB_PROJECT_ID',
        authDomain: 'YOUR_WEB_AUTH_DOMAIN',
        storageBucket: 'YOUR_WEB_STORAGE_BUCKET',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Konfigurasi untuk Firebase Android
        return const FirebaseOptions(
          apiKey: 'YOUR_ANDROID_API_KEY',
          appId: 'YOUR_ANDROID_APP_ID',
          messagingSenderId: 'YOUR_ANDROID_MESSAGING_SENDER_ID',
          projectId: 'YOUR_ANDROID_PROJECT_ID',
          storageBucket: 'YOUR_ANDROID_STORAGE_BUCKET',
        );
      case TargetPlatform.iOS:
        // Konfigurasi untuk Firebase iOS
        return const FirebaseOptions(
          apiKey: 'YOUR_IOS_API_KEY',
          appId: 'YOUR_IOS_APP_ID',
          messagingSenderId: 'YOUR_IOS_MESSAGING_SENDER_ID',
          projectId: 'YOUR_IOS_PROJECT_ID',
          storageBucket: 'YOUR_IOS_STORAGE_BUCKET',
          iosClientId: 'YOUR_IOS_CLIENT_ID',
          iosBundleId: 'YOUR_IOS_BUNDLE_ID',
        );
      case TargetPlatform.macOS:
        // Konfigurasi untuk Firebase macOS
        return const FirebaseOptions(
          apiKey: 'YOUR_MACOS_API_KEY',
          appId: 'YOUR_MACOS_APP_ID',
          messagingSenderId: 'YOUR_MACOS_MESSAGING_SENDER_ID',
          projectId: 'YOUR_MACOS_PROJECT_ID',
          storageBucket: 'YOUR_MACOS_STORAGE_BUCKET',
          iosBundleId: 'YOUR_MACOS_BUNDLE_ID',
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        throw UnsupportedError(
          'Platform tidak didukung oleh Firebase: ${defaultTargetPlatform}',
        );
    }
  }
} 
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class NotificationRepository {
  // Singleton
  static final NotificationRepository _instance = NotificationRepository._internal();
  factory NotificationRepository() => _instance;
  NotificationRepository._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  // Membuat notifikasi baru
  Future<void> createNotification(String message, {String? relatedId}) async {
    try {
      await _supabase.from('notifications').insert({
        'id': _uuid.v4(),
        'user_id': _supabase.auth.currentUser!.id,
        'message': message,
        'related_id': relatedId,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('Notifikasi berhasil dibuat: $message');
    } catch (e) {
      log('Error createNotification', error: e);
      debugPrint('Gagal membuat notifikasi: $e');
    }
  }

  // Mendapatkan semua notifikasi
  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error getAllNotifications', error: e);
      return [];
    }
  }

  // Mendapatkan jumlah notifikasi yang belum dibaca
  Future<int> getUnreadNotificationsCount() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', _supabase.auth.currentUser!.id)
          .eq('is_read', false);
      
      return (response as List).length;
    } catch (e) {
      log('Error getUnreadNotificationsCount', error: e);
      return 0;
    }
  }

  // Menandai notifikasi sebagai dibaca
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', _supabase.auth.currentUser!.id);
    } catch (e) {
      log('Error markAsRead', error: e);
      rethrow;
    }
  }

  // Menandai semua notifikasi sebagai dibaca
  Future<void> markAllAsRead() async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', _supabase.auth.currentUser!.id)
          .eq('is_read', false);
    } catch (e) {
      log('Error markAllAsRead', error: e);
      rethrow;
    }
  }

  // Menghapus notifikasi
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', _supabase.auth.currentUser!.id);
    } catch (e) {
      log('Error deleteNotification', error: e);
      rethrow;
    }
  }

  // Subscribe ke perubahan notifikasi
  Stream<List<Map<String, dynamic>>> notificationsStream() {
    try {
      // Untuk demo, kita simulasikan stream kosong
      // Pada implementasi sebenarnya, ini akan menggunakan Supabase realtime
      return Stream.value([]);
    } catch (e) {
      log('Error subscribing to notifications', error: e);
      return Stream.value([]);
    }
  }
} 
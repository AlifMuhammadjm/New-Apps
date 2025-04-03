import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CalendarService {
  // Singleton
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  // Menambahkan event ke Google Calendar
  Future<void> addToCalendar(String title, DateTime deadline, {String? description}) async {
    try {
      debugPrint('Menambahkan event ke calendar: $title pada $deadline');
      
      final event = {
        'summary': title,
        'description': description ?? 'Deadline Proyek',
        'start': {'dateTime': deadline.toIso8601String()},
        'end': {'dateTime': deadline.add(const Duration(hours: 1)).toIso8601String()},
        'reminders': {
          'useDefault': false,
          'overrides': [
            {'method': 'email', 'minutes': 24 * 60},
            {'method': 'popup', 'minutes': 60},
          ],
        },
      };

      // Simulasi untuk demo - sebenarnya akan memanggil Google Calendar API
      /*
      await http.post(
        Uri.parse('https://www.googleapis.com/calendar/v3/calendars/primary/events'),
        headers: await _getGoogleAuthHeaders(),
        body: jsonEncode(event),
      );
      */
      
      debugPrint('Event berhasil ditambahkan (simulasi): ${jsonEncode(event)}');
    } catch (e) {
      log('Error addToCalendar', error: e);
      debugPrint('Gagal menambahkan event ke kalender: $e');
    }
  }

  // Mendapatkan headers autentikasi Google (versi simulasi)
  Future<Map<String, String>> _getGoogleAuthHeaders() async {
    // Ini hanya simulasi, implementasi sebenarnya akan menggunakan OAuth2
    return {
      'Authorization': 'Bearer dummy_token',
      'Content-Type': 'application/json',
    };
  }
} 
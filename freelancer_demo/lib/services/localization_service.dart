import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service untuk mengelola lokalisasi dan bahasa aplikasi
/// termasuk fungsi untuk mendeteksi bahasa berdasarkan lokasi GPS
class LocalizationService {
  // Singleton
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  // Instance untuk mengubah bahasa
  final ValueNotifier<Locale> currentLocale = ValueNotifier<Locale>(const Locale('id'));

  // Daftar bahasa yang didukung
  final List<Locale> supportedLocales = [
    const Locale('id'), // Indonesia
    const Locale('en'), // English
    const Locale('es'), // Spanish
    const Locale('pt'), // Portuguese
  ];

  // Pemetaan kode negara ke kode bahasa
  final Map<String, String> _countryToLanguage = {
    'ID': 'id', // Indonesia
    'US': 'en', // United States
    'GB': 'en', // United Kingdom
    'AU': 'en', // Australia
    'ES': 'es', // Spain
    'MX': 'es', // Mexico
    'PT': 'pt', // Portugal
    'BR': 'pt', // Brazil
  };

  /// Mengganti bahasa secara manual
  void changeLocale(String languageCode) {
    currentLocale.value = Locale(languageCode);
    debugPrint('Bahasa diubah ke: $languageCode');
  }

  /// Mendapatkan bahasa berdasarkan lokasi GPS
  /// Menggunakan API reverse geocoding untuk mendapatkan negara
  Future<void> detectLanguageFromLocation(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1'),
        headers: {'User-Agent': 'FreelancerOS/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final countryCode = data['address']['country_code']?.toUpperCase();
        
        if (countryCode != null && _countryToLanguage.containsKey(countryCode)) {
          final languageCode = _countryToLanguage[countryCode]!;
          changeLocale(languageCode);
          debugPrint('Bahasa dideteksi berdasarkan lokasi ($countryCode): $languageCode');
        } else {
          debugPrint('Kode negara tidak didukung atau tidak ditemukan: $countryCode');
        }
      } else {
        debugPrint('Gagal mendapatkan lokasi: ${response.statusCode}');
      }
    } catch (e) {
      log('Error mendeteksi bahasa dari lokasi', error: e);
      debugPrint('Gagal mendeteksi bahasa dari lokasi: $e');
    }
  }

  /// Mendapatkan bahasa berdasarkan IP address
  /// Alternatif jika GPS tidak tersedia
  Future<void> detectLanguageFromIP() async {
    try {
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final countryCode = data['country_code'];
        
        if (countryCode != null && _countryToLanguage.containsKey(countryCode)) {
          final languageCode = _countryToLanguage[countryCode]!;
          changeLocale(languageCode);
          debugPrint('Bahasa dideteksi berdasarkan IP ($countryCode): $languageCode');
        } else {
          debugPrint('Kode negara dari IP tidak didukung: $countryCode');
        }
      } else {
        debugPrint('Gagal mendapatkan lokasi dari IP: ${response.statusCode}');
      }
    } catch (e) {
      log('Error mendeteksi bahasa dari IP', error: e);
      debugPrint('Gagal mendeteksi bahasa dari IP: $e');
    }
  }

  /// Mendapatkan teks selamat dalam bahasa yang digunakan
  String getGreetingByTime() {
    final hour = DateTime.now().hour;
    final locale = currentLocale.value.languageCode;
    
    if (locale == 'id') {
      if (hour < 10) return "Selamat Pagi";
      if (hour < 15) return "Selamat Siang";
      if (hour < 18) return "Selamat Sore";
      return "Selamat Malam";
    } else if (locale == 'es') {
      if (hour < 12) return "Buenos Días";
      if (hour < 19) return "Buenas Tardes";
      return "Buenas Noches";
    } else if (locale == 'pt') {
      if (hour < 12) return "Bom Dia";
      if (hour < 19) return "Boa Tarde";
      return "Boa Noite";
    } else {
      // Default English
      if (hour < 12) return "Good Morning";
      if (hour < 18) return "Good Afternoon";
      return "Good Evening";
    }
  }
} 
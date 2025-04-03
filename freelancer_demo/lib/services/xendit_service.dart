import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Service untuk integrasi dengan Xendit payment gateway (simulasi)
///
/// Catatan: Implementasi sebenarnya memerlukan SDK Xendit atau API calls langsung.
/// Untuk keamanan, API key Xendit seharusnya diakses dari backend, bukan dari aplikasi.
class XenditService {
  // Singleton
  static final XenditService _instance = XenditService._internal();
  factory XenditService() => _instance;
  XenditService._internal();

  // Harusnya API key ini disimpan di backend
  static const String _apiKey = 'YOUR_XENDIT_KEY';
  
  // Endpoint Xendit (simulasi)
  static const String _baseUrl = 'https://api.xendit.co';
  
  // Referensi ke Supabase
  final SupabaseClient _supabase = Supabase.instance.client;

  // Daftar bank yang didukung
  final List<Map<String, dynamic>> _supportedBanks = [
    {'code': 'BCA', 'name': 'Bank Central Asia', 'color': 0xFF0066AE},
    {'code': 'BNI', 'name': 'Bank Negara Indonesia', 'color': 0xFFF15A23},
    {'code': 'BRI', 'name': 'Bank Rakyat Indonesia', 'color': 0xFF00529C},
    {'code': 'MANDIRI', 'name': 'Bank Mandiri', 'color': 0xFF003F70},
    {'code': 'PERMATA', 'name': 'Bank Permata', 'color': 0xFF002855},
    {'code': 'BSI', 'name': 'Bank Syariah Indonesia', 'color': 0xFF006B71},
  ];

  // Dapatkan daftar bank yang didukung
  List<Map<String, dynamic>> get supportedBanks => _supportedBanks;

  /// Membuat Virtual Account untuk pembayaran
  Future<Map<String, dynamic>> createVirtualAccount(String bankCode, double amount, String name) async {
    try {
      debugPrint('Membuat virtual account Xendit untuk $name, Bank: $bankCode, Amount: $amount');
      
      // Di implementasi sebenarnya, ini akan memanggil Xendit API
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/virtual_accounts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ' + base64Encode(utf8.encode('$_apiKey:')),
        },
        body: jsonEncode({
          'external_id': 'VA_${DateTime.now().millisecondsSinceEpoch}',
          'bank_code': bankCode,
          'name': name,
          'expected_amount': amount,
          'is_closed': true,
          'expiration_date': DateTime.now().add(Duration(days: 1)).toIso8601String(),
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to create VA: ${response.body}');
      }
      
      final data = jsonDecode(response.body);
      */
      
      // Simulasi response
      final vaNumber = '${bankCode}${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8)}';
      final externalId = 'VA_${DateTime.now().millisecondsSinceEpoch}';
      
      // Simpan ke database
      await _saveTransaction(externalId, bankCode.toLowerCase(), amount, vaNumber);
      
      return {
        'bank_code': bankCode,
        'va_number': vaNumber,
        'amount': amount,
        'external_id': externalId,
        'expiration_date': DateTime.now().add(Duration(days: 1)).toIso8601String(),
      };
    } catch (e) {
      log('Error creating Xendit VA', error: e);
      rethrow;
    }
  }
  
  /// Menyimpan transaksi VA ke database
  Future<void> _saveTransaction(String externalId, String method, double amount, String vaNumber) async {
    try {
      await _supabase.from('payments').insert({
        'user_id': _supabase.auth.currentUser!.id,
        'amount': amount,
        'method': method,
        'txn_id': externalId,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'encrypted_details': vaNumber, // Dalam implementasi sebenarnya ini akan dienkripsi
      });
    } catch (e) {
      log('Error saving Xendit transaction', error: e);
    }
  }
  
  /// Memeriksa status pembayaran berdasarkan external_id
  Future<Map<String, dynamic>?> checkPaymentStatus(String externalId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('txn_id', externalId)
          .single();
      
      return response;
    } catch (e) {
      log('Error checking payment status', error: e);
      return null;
    }
  }

  /// Membuat Virtual Account
  Future<Map<String, dynamic>> createVirtualAccountWithDetails({
    required String externalId,
    required String bankCode,
    required String name,
    required double amount,
    bool isClosed = true,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v2/virtual_accounts'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Basic ' + base64Encode(utf8.encode('$_apiKey:')),
        },
        body: jsonEncode({
          'external_id': externalId,
          'bank_code': bankCode,
          'name': name,
          'is_closed': isClosed,
          'expected_amount': amount,
          'expiration_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
          'description': description ?? 'Pembayaran untuk layanan FreelanceGuard',
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseBody,
        };
      }

      return {
        'success': false,
        'message': 'Gagal membuat Virtual Account: ${responseBody['message'] ?? 'Unknown error'}',
      };
    } catch (e) {
      debugPrint('Error creating Xendit Virtual Account: $e');
      return {
        'success': false,
        'message': 'Gagal membuat Virtual Account: $e',
      };
    }
  }

  /// Mendapatkan status pembayaran Virtual Account
  Future<Map<String, dynamic>> getVirtualAccountStatus(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v2/virtual_accounts/$id'),
        headers: {
          'authorization': 'Basic ' + base64Encode(utf8.encode('$_apiKey:')),
        },
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseBody,
        };
      }

      return {
        'success': false,
        'message': 'Gagal mendapatkan status Virtual Account: ${responseBody['message'] ?? 'Unknown error'}',
      };
    } catch (e) {
      debugPrint('Error getting Xendit Virtual Account status: $e');
      return {
        'success': false,
        'message': 'Gagal mendapatkan status Virtual Account: $e',
      };
    }
  }

  /// Mendapatkan status pembayaran berdasarkan external ID
  Future<Map<String, dynamic>> getPaymentByExternalId(String externalId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v2/virtual_accounts?external_id=$externalId'),
        headers: {
          'authorization': 'Basic ' + base64Encode(utf8.encode('$_apiKey:')),
        },
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody is List && responseBody.isNotEmpty) {
          return {
            'success': true,
            'data': responseBody.first,
          };
        }
        return {
          'success': false,
          'message': 'Virtual Account tidak ditemukan',
        };
      }

      return {
        'success': false,
        'message': 'Gagal mendapatkan Virtual Account: ${responseBody['message'] ?? 'Unknown error'}',
      };
    } catch (e) {
      debugPrint('Error getting Xendit payment by external ID: $e');
      return {
        'success': false,
        'message': 'Gagal mendapatkan Virtual Account: $e',
      };
    }
  }

  /// Generate nomor referensi unik
  String generateExternalId(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp % 10000;
    return 'FG-$userId-$random';
  }
} 
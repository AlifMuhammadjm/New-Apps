import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:paypal_checkout/paypal_checkout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service untuk menangani pembayaran melalui PayPal
class PayPalService {
  // Singleton pattern
  static final PayPalService _instance = PayPalService._internal();
  factory PayPalService() => _instance;
  PayPalService._internal();

  // PayPal API credentials (contoh untuk sandbox)
  final String _clientId = 'YOUR_PAYPAL_CLIENT_ID';
  final String _secret = 'YOUR_PAYPAL_SECRET';
  
  // URL endpoint
  final String _baseUrl = kDebugMode 
      ? 'https://api-m.sandbox.paypal.com' // Sandbox untuk pengembangan
      : 'https://api-m.paypal.com';         // Production
  
  /// Mendapatkan token akses dari PayPal
  Future<String?> _getAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/oauth2/token'),
        headers: {
          'content-type': 'application/x-www-form-urlencoded',
          'authorization': 'Basic ' + base64Encode(utf8.encode('$_clientId:$_secret')),
        },
        body: 'grant_type=client_credentials',
      );
      
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['access_token'];
      }
      return null;
    } catch (e) {
      debugPrint('Error getting PayPal access token: $e');
      return null;
    }
  }
  
  /// Membuat pembayaran PayPal
  Future<Map<String, dynamic>> createPayment({
    required double amount,
    required String currency,
    required String description,
    required String returnUrl,
    required String cancelUrl,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      
      if (accessToken == null) {
        return {
          'success': false,
          'message': 'Tidak dapat terhubung ke PayPal',
        };
      }
      
      final body = {
        'intent': 'sale',
        'payer': {
          'payment_method': 'paypal',
        },
        'transactions': [
          {
            'amount': {
              'total': amount.toStringAsFixed(2),
              'currency': currency,
            },
            'description': description,
          }
        ],
        'redirect_urls': {
          'return_url': returnUrl,
          'cancel_url': cancelUrl,
        }
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/payments/payment'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );
      
      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        // Extract approval URL for redirecting user
        String? approvalUrl;
        String? paymentId;
        
        for (var link in responseBody['links']) {
          if (link['rel'] == 'approval_url') {
            approvalUrl = link['href'];
          }
        }
        
        paymentId = responseBody['id'];
        
        if (approvalUrl != null && paymentId != null) {
          return {
            'success': true,
            'approval_url': approvalUrl,
            'payment_id': paymentId,
          };
        }
      }
      
      return {
        'success': false,
        'message': 'Gagal membuat pembayaran PayPal: ${responseBody['message'] ?? 'Unknown error'}',
      };
    } catch (e) {
      debugPrint('Error creating PayPal payment: $e');
      return {
        'success': false,
        'message': 'Gagal membuat pembayaran PayPal: $e',
      };
    }
  }
  
  /// Memproses pembayaran setelah pengguna menyetujui 
  Future<Map<String, dynamic>> executePayment({
    required String paymentId,
    required String payerId,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      
      if (accessToken == null) {
        return {
          'success': false,
          'message': 'Tidak dapat terhubung ke PayPal',
        };
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/payments/payment/$paymentId/execute'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'payer_id': payerId}),
      );
      
      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Pembayaran berhasil
        final transactionId = responseBody['transactions'][0]['related_resources'][0]['sale']['id'];
        return {
          'success': true,
          'transaction_id': transactionId,
          'data': responseBody,
        };
      }
      
      return {
        'success': false,
        'message': 'Gagal menyelesaikan pembayaran: ${responseBody['message'] ?? 'Unknown error'}',
      };
    } catch (e) {
      debugPrint('Error executing PayPal payment: $e');
      return {
        'success': false,
        'message': 'Gagal menyelesaikan pembayaran: $e',
      };
    }
  }
  
  /// Mendapatkan detail pembayaran
  Future<Map<String, dynamic>> getPaymentDetails(String paymentId) async {
    try {
      final accessToken = await _getAccessToken();
      
      if (accessToken == null) {
        return {
          'success': false,
          'message': 'Tidak dapat terhubung ke PayPal',
        };
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/payments/payment/$paymentId'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $accessToken',
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
        'message': 'Gagal mendapatkan detail pembayaran: ${responseBody['message'] ?? 'Unknown error'}',
      };
    } catch (e) {
      debugPrint('Error getting PayPal payment details: $e');
      return {
        'success': false,
        'message': 'Gagal mendapatkan detail pembayaran: $e',
      };
    }
  }
} 
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class PaymentRepository {
  // Singleton
  static final PaymentRepository _instance = PaymentRepository._internal();
  factory PaymentRepository() => _instance;
  PaymentRepository._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Hold pembayaran di escrow
  Future<void> holdEscrow(String contractId, double amount) async {
    try {
      // 1. Simpan transaksi ke Supabase
      await _supabase.from('escrow_transactions').insert({
        'contract_id': contractId,
        'amount': amount,
        'status': 'held',
        'user_id': _supabase.auth.currentUser!.id,
        'created_at': DateTime.now().toIso8601String(),
      });

      // 2. Panggil API PayPal untuk hold dana - simulasi untuk demo
      /*
      final response = await http.post(
        Uri.parse('https://api.paypal.com/v1/payments/payouts'),
        headers: {'Authorization': 'Bearer YOUR_PAYPAL_TOKEN'},
        body: jsonEncode({
          'sender_batch_header': {'email_subject': 'Escrow Hold'},
          'items': [{
            'recipient_type': 'EMAIL',
            'amount': {'value': amount, 'currency': 'USD'},
            'receiver': 'escrow@yourdomain.com',
          }],
        }),
      );
      */
      
      debugPrint('Escrow hold berhasil (simulasi) untuk kontrak: $contractId, jumlah: $amount');
    } catch (e) {
      log('Error holdEscrow', error: e);
      rethrow;
    }
  }

  // Release dana dari escrow
  Future<void> releaseEscrow(String escrowId) async {
    try {
      // 1. Update status transaksi di Supabase
      await _supabase.from('escrow_transactions')
          .update({
            'status': 'released',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', escrowId)
          .eq('user_id', _supabase.auth.currentUser!.id);

      // 2. Panggil API PayPal untuk release dana - simulasi untuk demo
      /*
      final response = await http.post(
        Uri.parse('https://api.paypal.com/v1/payments/payouts/$escrowId/release'),
        headers: {'Authorization': 'Bearer YOUR_PAYPAL_TOKEN'},
      );
      */
      
      debugPrint('Escrow release berhasil (simulasi) untuk ID: $escrowId');
    } catch (e) {
      log('Error releaseEscrow', error: e);
      rethrow;
    }
  }

  // Refund dana dari escrow
  Future<void> refundEscrow(String escrowId) async {
    try {
      // 1. Update status transaksi di Supabase
      await _supabase.from('escrow_transactions')
          .update({
            'status': 'refunded',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', escrowId)
          .eq('user_id', _supabase.auth.currentUser!.id);

      // 2. Panggil API PayPal untuk refund dana - simulasi untuk demo
      /*
      final response = await http.post(
        Uri.parse('https://api.paypal.com/v1/payments/payouts/$escrowId/refund'),
        headers: {'Authorization': 'Bearer YOUR_PAYPAL_TOKEN'},
      );
      */
      
      debugPrint('Escrow refund berhasil (simulasi) untuk ID: $escrowId');
    } catch (e) {
      log('Error refundEscrow', error: e);
      rethrow;
    }
  }

  // Mendapatkan status escrow untuk kontrak
  Future<Map<String, dynamic>?> getEscrowForContract(String contractId) async {
    try {
      final response = await _supabase
          .from('escrow_transactions')
          .select()
          .eq('contract_id', contractId)
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('created_at', ascending: false)
          .maybeSingle();
      
      return response;
    } catch (e) {
      log('Error getEscrowForContract', error: e);
      return null;
    }
  }

  // Mendapatkan semua transaksi escrow
  Future<List<Map<String, dynamic>>> getAllEscrowTransactions() async {
    try {
      final response = await _supabase
          .from('escrow_transactions')
          .select('*, contracts!inner(project_name)')
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error getAllEscrowTransactions', error: e);
      return [];
    }
  }
} 
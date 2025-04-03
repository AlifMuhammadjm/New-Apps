import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/invoice.dart';

/// Repository for Invoice model
class InvoiceRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Singleton
  static final InvoiceRepository _instance = InvoiceRepository._internal();
  factory InvoiceRepository() => _instance;
  InvoiceRepository._internal();

  /// Get semua faktur
  Future<List<Invoice>> getInvoices() async {
    try {
      final response = await _supabase
          .from('invoices')
          .select()
          .order('created_at', ascending: false);

      return response.map<Invoice>((invoice) => Invoice.fromMap(invoice)).toList();
    } catch (e) {
      log('Error getInvoices', error: e);
      return [];
    }
  }

  /// Get faktur berdasarkan ID
  Future<Invoice?> getInvoiceById(String id) async {
    try {
      final response = await _supabase
          .from('invoices')
          .select()
          .eq('id', id)
          .single();

      return Invoice.fromMap(response);
    } catch (e) {
      log('Error getInvoiceById', error: e);
      return null;
    }
  }

  /// Create faktur baru
  Future<Invoice?> createInvoice(Invoice invoice) async {
    try {
      final response = await _supabase
          .from('invoices')
          .insert(invoice.toMap())
          .select()
          .single();

      return Invoice.fromMap(response);
    } catch (e) {
      log('Error createInvoice', error: e);
      return null;
    }
  }

  /// Update faktur
  Future<Invoice?> updateInvoice(Invoice invoice) async {
    try {
      final response = await _supabase
          .from('invoices')
          .update(invoice.toMap())
          .eq('id', invoice.id)
          .select()
          .single();

      return Invoice.fromMap(response);
    } catch (e) {
      log('Error updateInvoice', error: e);
      return null;
    }
  }

  /// Delete faktur
  Future<bool> deleteInvoice(String id) async {
    try {
      await _supabase
          .from('invoices')
          .delete()
          .eq('id', id);

      return true;
    } catch (e) {
      log('Error deleteInvoice', error: e);
      return false;
    }
  }

  /// Get faktur berdasarkan status
  Future<List<Invoice>> getInvoicesByStatus(String status) async {
    try {
      final response = await _supabase
          .from('invoices')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      return response.map<Invoice>((invoice) => Invoice.fromMap(invoice)).toList();
    } catch (e) {
      log('Error getInvoicesByStatus', error: e);
      return [];
    }
  }

  /// Simulasi upload file invoice
  Future<String> uploadInvoicePdf(File file) async {
    // Simulasi upload ke storage dan return URL
    return 'https://example.com/invoices/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }

  /// Stream faktur baru - versi stub
  Stream<Map<String, dynamic>> get invoiceStream {
    // Stub untuk contoh, selalu menghasilkan stream kosong
    return Stream.empty();
  }

  /// Mendapatkan jumlah faktur yang belum dibayar
  int getUnpaidInvoicesCount() {
    // Simulasi data untuk demo
    return 3;
  }

  /// Mendapatkan total nilai faktur yang belum dibayar
  double getTotalUnpaidInvoicesValue() {
    // Simulasi data untuk demo
    return 7500000.0;
  }
} 
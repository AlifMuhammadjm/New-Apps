import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/contract.dart';

/// Repository for Contract model
class ContractRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Singleton
  static final ContractRepository _instance = ContractRepository._internal();
  factory ContractRepository() => _instance;
  ContractRepository._internal();

  /// Get semua kontrak
  Future<List<Contract>> getContracts() async {
    try {
      final response = await _supabase
          .from('contracts')
          .select()
          .order('created_at', ascending: false);

      return response.map<Contract>((contract) => Contract.fromMap(contract)).toList();
    } catch (e) {
      log('Error getContracts', error: e);
      return [];
    }
  }

  /// Alias untuk getContracts untuk kompatibilitas
  Future<List<Contract>> getAllContracts() async {
    return getContracts();
  }

  /// Get kontrak berdasarkan ID
  Future<Contract?> getContractById(String id) async {
    try {
      final response = await _supabase
          .from('contracts')
          .select()
          .eq('id', id)
          .single();

      return Contract.fromMap(response);
    } catch (e) {
      log('Error getContractById', error: e);
      return null;
    }
  }

  /// Create kontrak baru
  Future<Contract?> createContract(Contract contract) async {
    try {
      final response = await _supabase
          .from('contracts')
          .insert(contract.toMap())
          .select()
          .single();

      return Contract.fromMap(response);
    } catch (e) {
      log('Error createContract', error: e);
      return null;
    }
  }

  /// Update kontrak
  Future<Contract?> updateContract(Contract contract) async {
    try {
      final response = await _supabase
          .from('contracts')
          .update(contract.toMap())
          .eq('id', contract.id)
          .select()
          .single();

      return Contract.fromMap(response);
    } catch (e) {
      log('Error updateContract', error: e);
      return null;
    }
  }

  /// Update status kontrak
  Future<Contract?> updateContractStatus(String id, String newStatus) async {
    try {
      final response = await _supabase
          .from('contracts')
          .update({'status': newStatus})
          .eq('id', id)
          .select()
          .single();

      return Contract.fromMap(response);
    } catch (e) {
      log('Error updateContractStatus', error: e);
      return null;
    }
  }

  /// Delete kontrak
  Future<bool> deleteContract(String id) async {
    try {
      await _supabase
          .from('contracts')
          .delete()
          .eq('id', id);

      return true;
    } catch (e) {
      log('Error deleteContract', error: e);
      return false;
    }
  }

  /// Get kontrak berdasarkan status
  Future<List<Contract>> getContractsByStatus(String status) async {
    try {
      final response = await _supabase
          .from('contracts')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      return response.map<Contract>((contract) => Contract.fromMap(contract)).toList();
    } catch (e) {
      log('Error getContractsByStatus', error: e);
      return [];
    }
  }

  /// Get kontrak untuk dashboard
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final activeContracts = await getContractsByStatus('active');
      final completedContracts = await getContractsByStatus('completed');

      final totalValueActive = activeContracts.fold(
          0.0, (prev, contract) => prev + (contract.value ?? 0));

      final totalValueCompleted = completedContracts.fold(
          0.0, (prev, contract) => prev + (contract.value ?? 0));

      return {
        'activeContracts': activeContracts.length,
        'completedContracts': completedContracts.length,
        'totalValueActive': totalValueActive,
        'totalValueCompleted': totalValueCompleted,
      };
    } catch (e) {
      log('Error getDashboardData', error: e);
      return {
        'activeContracts': 0,
        'completedContracts': 0,
        'totalValueActive': 0.0,
        'totalValueCompleted': 0.0,
      };
    }
  }

  /// Simulasi upload file
  Future<String> uploadPdf(File file) async {
    // Simulasi upload ke storage dan return URL
    return 'https://example.com/contracts/contract_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }

  /// Mendapatkan jumlah kontrak berdasarkan status
  int getContractCountByStatus(String status) {
    // Simulasi data untuk demo
    switch (status) {
      case 'active':
        return 5;
      case 'completed':
        return 12;
      case 'canceled':
        return 2;
      default:
        return 0;
    }
  }

  /// Mendapatkan total nilai kontrak aktif
  double getTotalActiveContractsValue() {
    // Simulasi data untuk demo
    return 12500000.0;
  }

  // Mendapatkan total pendapatan dari kontrak yang sudah selesai dalam tahun ini
  Future<double> getTotalIncomeThisYear() async {
    try {
      final now = DateTime.now();
      final yearStart = DateTime(now.year, 1, 1);
      
      final response = await _supabase
          .from('contracts')
          .select('value')
          .eq('user_id', _supabase.auth.currentUser!.id)
          .eq('status', 'completed')
          .gte('end_date', yearStart.toIso8601String());

      double total = 0;
      for (var item in response) {
        total += (item['value'] as num).toDouble();
      }
      
      return total;
    } catch (e) {
      log('Error getTotalIncomeThisYear', error: e);
      return 0; // Kembalikan 0 untuk menghindari crash
    }
  }

  // Format tanggal untuk tampilan
  String formatDate(DateTime date) {
    final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }
} 
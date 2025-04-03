import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freelancer_os/services/supabase_service.dart';
import 'package:freelancer_os/models/contract_model.dart';

class ContractRepository {
  final SupabaseClient _supabase = SupabaseService().client;

  // Singleton pattern
  static final ContractRepository _instance = ContractRepository._internal();
  factory ContractRepository() => _instance;
  ContractRepository._internal();

  // Mendapatkan semua kontrak untuk pengguna saat ini
  Future<List<Contract>> getContracts() async {
    try {
      final response = await _supabase
          .from('contracts')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Contract.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil kontrak: ${e.toString()}');
    }
  }

  // Menambahkan kontrak baru
  Future<Contract> addContract(String clientName, double value) async {
    try {
      final data = {
        'user_id': _supabase.auth.currentUser!.id,
        'client_name': clientName,
        'project_value': value,
      };
      
      final response = await _supabase
          .from('contracts')
          .insert(data)
          .select()
          .single();
      
      return Contract.fromJson(response);
    } catch (e) {
      throw Exception('Gagal menambahkan kontrak: ${e.toString()}');
    }
  }

  // Memperbarui kontrak yang ada
  Future<Contract> updateContract(String id, String clientName, double value) async {
    try {
      final data = {
        'client_name': clientName,
        'project_value': value,
      };
      
      final response = await _supabase
          .from('contracts')
          .update(data)
          .eq('id', id)
          .eq('user_id', _supabase.auth.currentUser!.id)
          .select()
          .single();
      
      return Contract.fromJson(response);
    } catch (e) {
      throw Exception('Gagal memperbarui kontrak: ${e.toString()}');
    }
  }

  // Menghapus kontrak yang ada
  Future<void> deleteContract(String id) async {
    try {
      await _supabase
          .from('contracts')
          .delete()
          .eq('id', id)
          .eq('user_id', _supabase.auth.currentUser!.id);
    } catch (e) {
      throw Exception('Gagal menghapus kontrak: ${e.toString()}');
    }
  }

  // Mendapatkan kontrak berdasarkan ID
  Future<Contract?> getContractById(String id) async {
    try {
      final response = await _supabase
          .from('contracts')
          .select()
          .eq('id', id)
          .eq('user_id', _supabase.auth.currentUser!.id)
          .single();
      
      return Contract.fromJson(response);
    } catch (e) {
      return null;
    }
  }
} 
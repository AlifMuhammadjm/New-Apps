import 'package:freelancer_os/models/contract_model.dart';
import 'package:freelancer_os/services/supabase_service.dart';

class ContractService {
  final SupabaseService _supabaseService = SupabaseService();
  final String _tableName = 'contracts';

  // Singleton pattern
  static final ContractService _instance = ContractService._internal();
  
  factory ContractService() {
    return _instance;
  }
  
  ContractService._internal();

  // Mendapatkan semua kontrak untuk user tertentu
  Future<List<Contract>> getContractsByUserId(String userId) async {
    final response = await _supabaseService
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => Contract.fromJson(json))
        .toList();
  }

  // Mendapatkan kontrak berdasarkan ID
  Future<Contract?> getContractById(String contractId) async {
    final response = await _supabaseService
        .from(_tableName)
        .select()
        .eq('id', contractId)
        .single();
    
    if (response == null) return null;
    return Contract.fromJson(response);
  }

  // Membuat kontrak baru
  Future<Contract> createContract(Contract contract) async {
    final response = await _supabaseService
        .from(_tableName)
        .insert(contract.toJson())
        .select()
        .single();
    
    return Contract.fromJson(response);
  }

  // Memperbarui kontrak
  Future<Contract> updateContract(Contract contract) async {
    final response = await _supabaseService
        .from(_tableName)
        .update(contract.toJson())
        .eq('id', contract.id)
        .select()
        .single();
    
    return Contract.fromJson(response);
  }

  // Menghapus kontrak
  Future<void> deleteContract(String contractId) async {
    await _supabaseService
        .from(_tableName)
        .delete()
        .eq('id', contractId);
  }
} 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freelancer_os/models/contract.dart';
import 'package:freelancer_os/models/invoice.dart';
import 'package:freelancer_os/models/financial_report.dart';
import 'package:freelancer_os/models/subscription.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  static late final SupabaseClient _supabaseClient;

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  // Inisialisasi Supabase
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    _supabaseClient = Supabase.instance.client;
  }

  // Akses ke client Supabase
  static SupabaseClient get client => _supabaseClient;
  
  // Mendapatkan user saat ini
  static User? get currentUser => _supabaseClient.auth.currentUser;
  
  // Mendaftar user baru
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _supabaseClient.auth.signUp(
      email: email,
      password: password,
    );
  }
  
  // Login dengan email dan password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  // Logout
  static Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }
  
  // Menambahkan kontrak baru
  static Future<Contract> addContract(Contract contract) async {
    final response = await _supabaseClient
        .from('contracts')
        .insert(contract.toJson())
        .select()
        .single();
    
    return Contract.fromJson(response);
  }
  
  // Mendapatkan semua kontrak untuk user saat ini
  static Future<List<Contract>> getContracts() async {
    final response = await _supabaseClient
        .from('contracts')
        .select()
        .order('created_at', ascending: false);
    
    return response.map<Contract>((data) => Contract.fromJson(data)).toList();
  }
  
  // Mendapatkan detail kontrak berdasarkan ID
  static Future<Contract> getContractById(String id) async {
    final response = await _supabaseClient
        .from('contracts')
        .select()
        .eq('id', id)
        .single();
    
    return Contract.fromJson(response);
  }
  
  // Memperbarui kontrak yang ada
  static Future<Contract> updateContract(Contract contract) async {
    final response = await _supabaseClient
        .from('contracts')
        .update(contract.toJson())
        .eq('id', contract.id)
        .select()
        .single();
    
    return Contract.fromJson(response);
  }
  
  // Menghapus kontrak
  static Future<void> deleteContract(String id) async {
    await _supabaseClient
        .from('contracts')
        .delete()
        .eq('id', id);
  }
  
  // Stream untuk mendapatkan update kontrak secara real-time
  static Stream<List<Contract>> streamContracts() {
    return _supabaseClient
        .from('contracts')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) => data.map<Contract>((item) => Contract.fromJson(item)).toList());
  }
  
  // Menambahkan invoice baru
  static Future<Invoice> addInvoice(Invoice invoice) async {
    final response = await _supabaseClient
        .from('invoices')
        .insert(invoice.toJson())
        .select()
        .single();
    
    return Invoice.fromJson(response);
  }
  
  // Mendapatkan semua invoice untuk user saat ini
  static Future<List<Invoice>> getInvoices() async {
    final response = await _supabaseClient
        .from('invoices')
        .select()
        .order('created_at', ascending: false);
    
    return response.map<Invoice>((data) => Invoice.fromJson(data)).toList();
  }
  
  // Mendapatkan invoice untuk kontrak tertentu
  static Future<List<Invoice>> getInvoicesByContractId(String contractId) async {
    final response = await _supabaseClient
        .from('invoices')
        .select()
        .eq('contract_id', contractId)
        .order('created_at', ascending: false);
    
    return response.map<Invoice>((data) => Invoice.fromJson(data)).toList();
  }
  
  // Memperbarui status invoice
  static Future<void> updateInvoiceStatus(String id, String status) async {
    await _supabaseClient
        .from('invoices')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }
  
  // Menghapus invoice
  static Future<void> deleteInvoice(String id) async {
    await _supabaseClient
        .from('invoices')
        .delete()
        .eq('id', id);
  }
  
  // Menambahkan langganan baru
  static Future<Subscription> addSubscription(Subscription subscription) async {
    final response = await _supabaseClient
        .from('subscriptions')
        .insert(subscription.toJson())
        .select()
        .single();
    
    return Subscription.fromJson(response);
  }
  
  // Mendapatkan langganan aktif untuk user saat ini
  static Future<Subscription?> getActiveSubscription() async {
    try {
      final response = await _supabaseClient
          .from('subscriptions')
          .select()
          .eq('status', 'active')
          .limit(1)
          .single();
      
      return Subscription.fromJson(response);
    } catch (e) {
      return null; // Tidak ada langganan aktif
    }
  }
  
  // Memperbarui status langganan
  static Future<void> updateSubscriptionStatus(String id, String status) async {
    await _supabaseClient
        .from('subscriptions')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }
  
  // Menghitung total nilai proyek
  static Future<double> calculateTotalProjectValue() async {
    try {
      final result = await _supabaseClient.rpc(
        'execute_sql',
        params: {
          'sql_query': '''
          SELECT COALESCE(SUM(project_value), 0) as total
          FROM contracts
          WHERE user_id = auth.uid()
          '''
        }
      );
      
      if (result == null) return 0;
      return double.parse(result.toString());
    } catch (e) {
      return 0;
    }
  }
  
  // Mendapatkan laporan keuangan bulanan
  static Future<List<FinancialReport>> getMonthlyFinancialReport() async {
    try {
      final result = await _supabaseClient.rpc(
        'execute_sql',
        params: {
          'sql_query': '''
          SELECT 
            date_trunc('month', created_at) as month,
            COUNT(*) as contracts_count,
            COALESCE(SUM(project_value), 0) as total_value
          FROM contracts
          WHERE user_id = auth.uid()
          GROUP BY date_trunc('month', created_at)
          ORDER BY month DESC
          LIMIT 6
          '''
        }
      );
      
      if (result == null) return [];
      
      final List<dynamic> data = result as List<dynamic>;
      return data.map((item) => FinancialReport.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }
  
  // Menjalankan SQL kustom
  static Future<dynamic> executeCustomSQL(String sqlQuery) async {
    try {
      return await _supabaseClient.rpc(
        'execute_sql',
        params: {'sql_query': sqlQuery}
      );
    } catch (e) {
      rethrow;
    }
  }
} 
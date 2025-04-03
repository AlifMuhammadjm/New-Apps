import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client.dart';

class ClientRepository {
  static final ClientRepository _instance = ClientRepository._internal();
  factory ClientRepository() => _instance;
  ClientRepository._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Mendapatkan semua klien untuk pengguna saat ini
  Future<List<Client>> getAllClients() async {
    final response = await _supabase
        .from('clients')
        .select()
        .eq('user_id', _supabase.auth.currentUser!.id)
        .order('created_at', ascending: false);

    return (response as List).map((data) => Client.fromMap(data)).toList();
  }

  // Mendapatkan klien berdasarkan ID
  Future<Client?> getClientById(String id) async {
    final response = await _supabase
        .from('clients')
        .select()
        .eq('id', id)
        .eq('user_id', _supabase.auth.currentUser!.id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Client.fromMap(response);
  }

  // Mencari klien berdasarkan nama atau email
  Future<List<Client>> searchClients(String searchTerm) async {
    final lowerSearchTerm = searchTerm.toLowerCase();
    
    final response = await _supabase
        .from('clients')
        .select()
        .eq('user_id', _supabase.auth.currentUser!.id)
        .or('name.ilike.%$lowerSearchTerm%,email.ilike.%$lowerSearchTerm%,company_name.ilike.%$lowerSearchTerm%');

    return (response as List).map((data) => Client.fromMap(data)).toList();
  }

  // Menambahkan klien baru
  Future<Client> addClient(Client client) async {
    final data = client.toMap();
    data.remove('id'); // Hapus id karena akan digenerate oleh Supabase
    data['user_id'] = _supabase.auth.currentUser!.id;
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase.from('clients').insert(data).select();
    return Client.fromMap(response[0]);
  }

  // Memperbarui data klien
  Future<Client> updateClient(Client client) async {
    final data = client.toMap();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('clients')
        .update(data)
        .eq('id', client.id)
        .eq('user_id', _supabase.auth.currentUser!.id)
        .select();

    return Client.fromMap(response[0]);
  }

  // Menghapus klien
  Future<void> deleteClient(String id) async {
    await _supabase
        .from('clients')
        .delete()
        .eq('id', id)
        .eq('user_id', _supabase.auth.currentUser!.id);
  }

  // Upload foto profil klien
  Future<String> uploadProfilePicture(File file) async {
    final path = 'clients/${_supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _supabase.storage.from('images').upload(path, file);
    return _supabase.storage.from('images').getPublicUrl(path);
  }

  // Mendapatkan jumlah klien aktif
  Future<int> getActiveClientsCount() async {
    // Klien aktif adalah yang memiliki setidaknya satu kontrak aktif
    final response = await _supabase
        .from('clients')
        .select('id, contracts!inner(*)')
        .eq('user_id', _supabase.auth.currentUser!.id)
        .eq('contracts.status', 'active')
        .execute();

    // Menghitung jumlah klien unik
    final uniqueClientIds = (response.data as List).map((item) => item['id'] as String).toSet();
    return uniqueClientIds.length;
  }

  // Mendapatkan jumlah total klien
  Future<int> getTotalClientsCount() async {
    final response = await _supabase
        .from('clients')
        .select('count', const FetchOptions(count: CountOption.exact))
        .eq('user_id', _supabase.auth.currentUser!.id);

    return response.count ?? 0;
  }
} 
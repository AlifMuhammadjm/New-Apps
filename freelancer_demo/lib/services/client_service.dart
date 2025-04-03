import 'package:uuid/uuid.dart';
import '../models/client.dart';

class ClientService {
  // Singleton pattern
  static final ClientService _instance = ClientService._internal();
  factory ClientService() => _instance;
  ClientService._internal();

  // Simulasi database klien
  final List<Client> _clients = [
    Client(
      id: '1',
      name: 'Budi Santoso',
      email: 'budi@example.com',
      phoneNumber: '081234567890',
      companyName: 'PT Maju Bersama',
      address: 'Jl. Pahlawan No. 123, Jakarta',
      notes: 'Klien sejak 2022, sangat kooperatif',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Client(
      id: '2',
      name: 'Dewi Lestari',
      email: 'dewi@example.com',
      phoneNumber: '087654321098',
      companyName: 'CV Teknologi Masa Depan',
      address: 'Jl. Sudirman No. 45, Bandung',
      notes: 'Sering meminta revisi, tetapi pembayaran selalu tepat waktu',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
    ),
    Client(
      id: '3',
      name: 'Ahmad Hidayat',
      email: 'ahmad@example.com',
      phoneNumber: '089876543210',
      companyName: 'Yayasan Pendidikan Nusantara',
      address: 'Jl. Pendidikan No. 78, Surabaya',
      notes: 'Melakukan pembayaran melalui transfer bank BCA',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
    Client(
      id: '4',
      name: 'Siti Rahayu',
      email: 'siti@example.com',
      phoneNumber: '082345678901',
      companyName: 'UD Karya Mandiri',
      address: 'Jl. Veteran No. 56, Yogyakarta',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    Client(
      id: '5',
      name: 'Joko Widodo',
      email: 'joko@example.com',
      phoneNumber: '081987654321',
      companyName: 'PT Sejahtera Abadi',
      address: 'Jl. Merdeka No. 17, Solo',
      notes: 'Memerlukan faktur pajak untuk setiap pembayaran',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  // Mendapatkan semua klien
  List<Client> getAllClients() {
    return List.from(_clients);
  }

  // Mendapatkan klien berdasarkan ID
  Client? getClientById(String id) {
    try {
      return _clients.firstWhere((client) => client.id == id);
    } catch (e) {
      return null;
    }
  }

  // Mencari klien berdasarkan kata kunci
  List<Client> searchClients(String query) {
    final lowerQuery = query.toLowerCase();
    return _clients.where((client) =>
      client.name.toLowerCase().contains(lowerQuery) ||
      client.email.toLowerCase().contains(lowerQuery) ||
      (client.companyName?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }

  // Menambahkan klien baru
  Client addClient({
    required String name,
    required String email,
    String? phoneNumber,
    String? companyName,
    String? address,
    String? notes,
    String? profilePictureUrl,
  }) {
    final uuid = const Uuid();
    final newClient = Client(
      id: uuid.v4(),
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      companyName: companyName,
      address: address,
      notes: notes,
      createdAt: DateTime.now(),
      profilePictureUrl: profilePictureUrl,
    );
    
    _clients.add(newClient);
    return newClient;
  }

  // Memperbarui klien
  bool updateClient(Client updatedClient) {
    final index = _clients.indexWhere((client) => client.id == updatedClient.id);
    if (index >= 0) {
      _clients[index] = updatedClient;
      return true;
    }
    return false;
  }

  // Menghapus klien
  bool deleteClient(String id) {
    final index = _clients.indexWhere((client) => client.id == id);
    if (index >= 0) {
      _clients.removeAt(index);
      return true;
    }
    return false;
  }

  // Mendapatkan jumlah total klien
  int getTotalClientsCount() {
    return _clients.length;
  }

  // Mendapatkan klien yang memiliki kontrak aktif
  int getActiveClientsCount() {
    // Untuk demo, kita asumsikan 3 klien memiliki kontrak aktif
    return 3;
  }
} 
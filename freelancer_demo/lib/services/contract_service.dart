import 'package:uuid/uuid.dart';
import '../models/contract.dart';

class ContractService {
  // Singleton pattern
  static final ContractService _instance = ContractService._internal();
  factory ContractService() => _instance;
  ContractService._internal();

  // Simulasi database kontrak
  final List<Contract> _contracts = [
    Contract(
      id: '1',
      clientName: 'PT Maju Bersama',
      projectName: 'Pengembangan Aplikasi E-commerce',
      value: 15000000,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 60)),
      status: 'active',
      description: 'Pengembangan aplikasi e-commerce berbasis Flutter dengan backend Firebase.',
    ),
    Contract(
      id: '2',
      clientName: 'CV Teknologi Masa Depan',
      projectName: 'Redesign Website Perusahaan',
      value: 8500000,
      startDate: DateTime.now().subtract(const Duration(days: 15)),
      endDate: DateTime.now().add(const Duration(days: 15)),
      status: 'active',
      description: 'Redesign website perusahaan dengan fokus pada UX dan responsivitas.',
    ),
    Contract(
      id: '3',
      clientName: 'Yayasan Pendidikan Nusantara',
      projectName: 'Aplikasi Manajemen Sekolah',
      value: 25000000,
      startDate: DateTime.now().subtract(const Duration(days: 60)),
      endDate: DateTime.now().subtract(const Duration(days: 10)),
      status: 'completed',
      description: 'Pengembangan sistem manajemen sekolah terintegrasi dengan modul absensi, nilai, dan keuangan.',
    ),
  ];

  // Mendapatkan semua kontrak
  List<Contract> getAllContracts() {
    return List.from(_contracts);
  }

  // Mendapatkan kontrak berdasarkan status
  List<Contract> getContractsByStatus(String status) {
    return _contracts.where((contract) => contract.status == status).toList();
  }

  // Mendapatkan kontrak berdasarkan ID
  Contract? getContractById(String id) {
    try {
      return _contracts.firstWhere((contract) => contract.id == id);
    } catch (e) {
      return null;
    }
  }

  // Menambahkan kontrak baru
  Contract addContract({
    required String clientName,
    required String projectName,
    required double value,
    required DateTime startDate,
    required DateTime endDate,
    required String description,
  }) {
    final uuid = const Uuid();
    final newContract = Contract(
      id: uuid.v4(),
      clientName: clientName,
      projectName: projectName,
      value: value,
      startDate: startDate,
      endDate: endDate,
      status: 'active',
      description: description,
    );
    
    _contracts.add(newContract);
    return newContract;
  }

  // Memperbarui kontrak
  bool updateContract(Contract updatedContract) {
    final index = _contracts.indexWhere((contract) => contract.id == updatedContract.id);
    if (index >= 0) {
      _contracts[index] = updatedContract;
      return true;
    }
    return false;
  }

  // Mengubah status kontrak
  bool updateContractStatus(String id, String newStatus) {
    final index = _contracts.indexWhere((contract) => contract.id == id);
    if (index >= 0) {
      final contract = _contracts[index];
      _contracts[index] = contract.copyWith(status: newStatus);
      return true;
    }
    return false;
  }

  // Menghapus kontrak
  bool deleteContract(String id) {
    final index = _contracts.indexWhere((contract) => contract.id == id);
    if (index >= 0) {
      _contracts.removeAt(index);
      return true;
    }
    return false;
  }

  // Mendapatkan total nilai kontrak aktif
  double getTotalActiveContractsValue() {
    return _contracts
        .where((contract) => contract.status == 'active')
        .fold(0, (sum, contract) => sum + contract.value);
  }

  // Mendapatkan jumlah kontrak berdasarkan status
  int getContractCountByStatus(String status) {
    return _contracts.where((contract) => contract.status == status).length;
  }
} 
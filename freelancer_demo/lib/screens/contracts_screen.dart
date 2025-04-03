import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:file_picker/file_picker.dart';
import '../models/contract.dart';
import '../repositories/contract_repository.dart';
import '../services/notification_service.dart';
import '../utils/pdf_generator.dart';
import 'contract_detail_screen.dart';
import 'contract_form_screen.dart';

class ContractsScreen extends StatefulWidget {
  const ContractsScreen({Key? key}) : super(key: key);

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ContractRepository _contractRepository = ContractRepository();
  final NotificationService _notificationService = NotificationService();
  final PdfGenerator _pdfGenerator = PdfGenerator();
  
  bool _isLoading = true;
  List<Contract> _allContracts = [];
  List<Contract> _activeContracts = [];
  List<Contract> _completedContracts = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadContracts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadContracts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allContracts = await _contractRepository.getAllContracts();
      final activeContracts = await _contractRepository.getContractsByStatus('active');
      final completedContracts = await _contractRepository.getContractsByStatus('completed');

      setState(() {
        _allContracts = allContracts;
        _activeContracts = activeContracts;
        _completedContracts = completedContracts;
      });
    } catch (e) {
      _notificationService.showFlutterToast('Gagal memuat kontrak: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToContractForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContractFormScreen()),
    );

    if (result == true) {
      _loadContracts();
    }
  }

  Future<void> _generateAndDownloadContract(Contract contract) async {
    try {
      final file = await _pdfGenerator.generateContractPdf(contract);
      await _pdfGenerator.openPdf(file);
      _notificationService.showFlutterToast('Dokumen kontrak berhasil dibuat');
    } catch (e) {
      _notificationService.showFlutterToast('Gagal membuat dokumen: ${e.toString()}');
    }
  }

  Future<void> _uploadContractDocument(Contract contract) async {
    try {
      // Menonaktifkan file picker untuk demo
      /*
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
      */

      _notificationService.showFlutterToast('Fitur unggah dokumen dinonaktifkan dalam demo');
      
      // Simulasi update kontrak dengan URL dokumen dummy
      final updatedContract = contract.copyWith(documentUrl: 'https://example.com/dummy-contract.pdf');
      await _contractRepository.updateContract(updatedContract);
      
      _notificationService.showFlutterToast('Dokumen kontrak berhasil diunggah (simulasi)');
      _loadContracts();
      
    } catch (e) {
      _notificationService.showFlutterToast('Gagal mengunggah dokumen: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kontrak'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContracts,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Aktif'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildContractList(_allContracts),
                _buildContractList(_activeContracts),
                _buildContractList(_completedContracts),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToContractForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContractList(List<Contract> contracts) {
    if (contracts.isEmpty) {
      return const Center(
        child: Text('Tidak ada kontrak untuk ditampilkan'),
      );
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return RefreshIndicator(
      onRefresh: _loadContracts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          final contract = contracts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 2.0,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContractDetailScreen(contractId: contract.id),
                  ),
                ).then((_) => _loadContracts());
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            contract.projectName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(contract.status),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Klien: ${contract.clientName}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Nilai: ${currencyFormat.format(contract.value)}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16.0),
                        const SizedBox(width: 4.0),
                        Text(
                          '${_formatDate(contract.startDate)} - ${_formatDate(contract.endDate)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          onPressed: () => _generateAndDownloadContract(contract),
                          tooltip: 'Buat PDF kontrak',
                        ),
                        IconButton(
                          icon: const Icon(Icons.upload_file, color: Colors.blue),
                          onPressed: () => _uploadContractDocument(contract),
                          tooltip: 'Unggah dokumen kontrak',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String statusText;

    switch (status) {
      case 'active':
        badgeColor = Colors.green;
        statusText = 'Aktif';
        break;
      case 'completed':
        badgeColor = Colors.blue;
        statusText = 'Selesai';
        break;
      case 'canceled':
        badgeColor = Colors.red;
        statusText = 'Dibatalkan';
        break;
      default:
        badgeColor = Colors.grey;
        statusText = 'Lainnya';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 12.0,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
} 
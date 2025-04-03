import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contract.dart';
import '../repositories/contract_repository.dart';
import '../services/notification_service.dart';
import '../utils/pdf_generator.dart';
import 'contract_form_screen.dart';

class ContractDetailScreen extends StatefulWidget {
  final String contractId;

  const ContractDetailScreen({
    Key? key,
    required this.contractId,
  }) : super(key: key);

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen> {
  final ContractRepository _contractRepository = ContractRepository();
  final NotificationService _notificationService = NotificationService();
  final PdfGenerator _pdfGenerator = PdfGenerator();
  
  late Contract? _contract;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContract();
  }

  Future<void> _loadContract() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final contract = await _contractRepository.getContractById(widget.contractId);
      
      setState(() {
        _contract = contract;
      });
    } catch (e) {
      _notificationService.showFlutterToast('Gagal memuat kontrak: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _editContract() async {
    if (_contract == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContractFormScreen(initialContract: _contract),
      ),
    );

    if (result == true) {
      _loadContract();
    }
  }

  Future<void> _generateAndDownloadContract() async {
    if (_contract == null) return;
    
    try {
      final file = await _pdfGenerator.generateContractPdf(_contract!);
      await _pdfGenerator.openPdf(file);
      _notificationService.showFlutterToast('Dokumen kontrak berhasil dibuat');
    } catch (e) {
      _notificationService.showFlutterToast('Gagal membuat dokumen: ${e.toString()}');
    }
  }

  Future<void> _uploadContractDocument() async {
    if (_contract == null) return;
    
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

        _notificationService.showFlutterToast('Mengunggah dokumen kontrak...');
        
        // Upload PDF ke Supabase Storage
        final documentUrl = await _contractRepository.uploadPdf(file);
      */
      
      _notificationService.showFlutterToast('Fitur unggah dokumen dinonaktifkan dalam demo');
        
      // Simulasi update kontrak dengan URL dokumen dummy
      final updatedContract = _contract!.copyWith(documentUrl: 'https://example.com/dummy-contract.pdf');
      await _contractRepository.updateContract(updatedContract);
      
      _notificationService.showFlutterToast('Dokumen kontrak berhasil diunggah (simulasi)');
      _loadContract();
      
    } catch (e) {
      _notificationService.showFlutterToast('Gagal mengunggah dokumen: ${e.toString()}');
    }
  }

  Future<void> _viewContractDocument() async {
    if (_contract == null || _contract!.documentUrl == null) return;
    
    try {
      final url = Uri.parse(_contract!.documentUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _notificationService.showFlutterToast('Tidak dapat membuka dokumen');
      }
    } catch (e) {
      _notificationService.showFlutterToast('Gagal membuka dokumen: ${e.toString()}');
    }
  }

  Future<void> _showStatusChangeConfirmation(String newStatus, String statusText) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Status Kontrak'),
        content: Text('Apakah Anda yakin ingin mengubah status kontrak menjadi "$statusText"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _changeContractStatus(newStatus);
            },
            child: const Text('Ya, Ubah Status'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeContractStatus(String newStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _contractRepository.updateContractStatus(widget.contractId, newStatus);
      
      _notificationService.showFlutterToast('Status kontrak berhasil diubah');
      _loadContract();
    } catch (e) {
      _notificationService.showFlutterToast('Gagal mengubah status kontrak: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kontrak'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editContract,
            tooltip: 'Edit Kontrak',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contract == null
              ? const Center(child: Text('Kontrak tidak ditemukan'))
              : _buildContractDetails(),
    );
  }

  Widget _buildContractDetails() {
    final contract = _contract!;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(contract),
          const SizedBox(height: 24.0),
          _buildSection(
            title: 'Informasi Project',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Nama Project', contract.projectName),
                _buildInfoRow('Nilai Kontrak', currencyFormat.format(contract.value)),
                _buildInfoRow('Tanggal Mulai', _formatDate(contract.startDate)),
                _buildInfoRow('Tanggal Selesai', _formatDate(contract.endDate)),
                _buildInfoRow('Status', _getStatusText(contract.status)),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          _buildSection(
            title: 'Informasi Klien',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Nama Klien', contract.clientName),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          _buildSection(
            title: 'Deskripsi Project',
            child: Text(
              contract.description,
              style: const TextStyle(
                fontSize: 16.0,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          _buildDocumentSection(contract),
          const SizedBox(height: 24.0),
          _buildActionButtons(contract),
        ],
      ),
    );
  }

  Widget _buildHeader(Contract contract) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contract.projectName,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'ID: ${contract.id}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(contract.status),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const Divider(),
        const SizedBox(height: 8.0),
        child,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.0,
            child: Text(
              label + ':',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection(Contract contract) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dokumen Kontrak',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const Divider(),
        const SizedBox(height: 8.0),
        contract.documentUrl != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.insert_drive_file, color: Colors.blue),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'Dokumen kontrak tersedia',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        onPressed: _viewContractDocument,
                        tooltip: 'Lihat Dokumen',
                      ),
                    ],
                  ),
                ],
              )
            : Text(
                'Tidak ada dokumen kontrak yang diunggah',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Buat PDF'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                onPressed: _generateAndDownloadContract,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Unggah Dokumen'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                onPressed: _uploadContractDocument,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(Contract contract) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (contract.status == 'active')
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Tandai sebagai Selesai'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
            onPressed: () {
              _showStatusChangeConfirmation('completed', 'Selesai');
            },
          ),
        if (contract.status == 'active')
          const SizedBox(height: 12.0),
        if (contract.status == 'active')
          OutlinedButton.icon(
            icon: const Icon(Icons.cancel, color: Colors.red),
            label: const Text(
              'Batalkan Kontrak',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
            onPressed: () {
              _showStatusChangeConfirmation('canceled', 'Dibatalkan');
            },
          ),
        if (contract.status != 'active')
          ElevatedButton.icon(
            icon: const Icon(Icons.restart_alt),
            label: const Text('Aktifkan Kembali'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
            onPressed: () {
              _showStatusChangeConfirmation('active', 'Aktif');
            },
          ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String statusText = _getStatusText(status);

    switch (status) {
      case 'active':
        badgeColor = Colors.green;
        break;
      case 'completed':
        badgeColor = Colors.blue;
        break;
      case 'canceled':
        badgeColor = Colors.red;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 14.0,
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'completed':
        return 'Selesai';
      case 'canceled':
        return 'Dibatalkan';
      default:
        return 'Lainnya';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }
} 
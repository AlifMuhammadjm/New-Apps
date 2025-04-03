import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/contract.dart';
import '../repositories/contract_repository.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class ContractFormScreen extends StatefulWidget {
  final Contract? initialContract;

  const ContractFormScreen({
    Key? key,
    this.initialContract,
  }) : super(key: key);

  @override
  State<ContractFormScreen> createState() => _ContractFormScreenState();
}

class _ContractFormScreenState extends State<ContractFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  bool _isEditing = false;

  final ContractRepository _contractRepository = ContractRepository();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.initialContract != null;
    _populateFormIfEditing();
  }

  void _populateFormIfEditing() {
    if (widget.initialContract != null) {
      final contract = widget.initialContract!;
      
      _clientNameController.text = contract.clientName;
      _projectNameController.text = contract.projectName;
      _valueController.text = contract.value.toString();
      
      _startDate = contract.startDate;
      _endDate = contract.endDate;
      
      _startDateController.text = DateFormat('dd/MM/yyyy').format(_startDate!);
      _endDateController.text = DateFormat('dd/MM/yyyy').format(_endDate!);
      
      _descriptionController.text = contract.description;
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _projectNameController.dispose();
    _valueController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final today = DateTime.now();
    final firstDate = isStartDate 
      ? DateTime(today.year - 1, today.month, today.day)
      : _startDate ?? DateTime(today.year - 1, today.month, today.day);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? today,
      firstDate: firstDate,
      lastDate: DateTime(today.year + 5, today.month, today.day),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);
          
          // Jika tanggal mulai setelah tanggal selesai, reset tanggal selesai
          if (_endDate != null && _startDate!.isAfter(_endDate!)) {
            _endDate = null;
            _endDateController.clear();
          }
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }

  Future<void> _saveContract() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final clientName = _clientNameController.text;
        final projectName = _projectNameController.text;
        final value = double.parse(_valueController.text.replaceAll(',', ''));
        final description = _descriptionController.text;

        if (_isEditing) {
          // Update kontrak yang sudah ada
          final updatedContract = widget.initialContract!.copyWith(
            clientName: clientName,
            projectName: projectName,
            value: value,
            startDate: _startDate,
            endDate: _endDate,
            description: description,
          );

          await _contractRepository.updateContract(updatedContract);
          _notificationService.showFlutterToast('Kontrak berhasil diperbarui');
        } else {
          // Buat kontrak baru
          final uuid = const Uuid();
          final newContract = Contract(
            id: uuid.v4(),
            clientName: clientName,
            projectName: projectName,
            value: value,
            startDate: _startDate!,
            endDate: _endDate!,
            status: 'active',
            description: description,
          );

          await _contractRepository.createContract(newContract);
          _notificationService.showFlutterToast('Kontrak baru berhasil ditambahkan');
        }

        if (mounted) {
          Navigator.pop(context, true); // true menandakan perubahan berhasil
        }
      } catch (e) {
        _notificationService.showFlutterToast('Gagal menyimpan kontrak: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Kontrak' : 'Kontrak Baru'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _clientNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Klien',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama klien tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _projectNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Proyek',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama proyek tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _valueController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nilai Kontrak (Rp)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monetization_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nilai kontrak tidak boleh kosong';
                        }
                        try {
                          final amount = double.parse(value.replaceAll(',', ''));
                          if (amount <= 0) {
                            return 'Nilai kontrak harus lebih dari 0';
                          }
                        } catch (e) {
                          return 'Masukkan nilai numerik yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startDateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Mulai',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () => _selectDate(context, true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Pilih tanggal mulai';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: TextFormField(
                            controller: _endDateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Selesai',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.event),
                            ),
                            onTap: () => _selectDate(context, false),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Pilih tanggal selesai';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Pekerjaan',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton.icon(
                      onPressed: _saveContract,
                      icon: const Icon(Icons.save),
                      label: Text(_isEditing ? 'Perbarui Kontrak' : 'Simpan Kontrak'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 
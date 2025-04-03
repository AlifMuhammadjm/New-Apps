import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freelancer_os/models/contract_model.dart';
import 'package:freelancer_os/repositories/auth_repository.dart';
import 'package:freelancer_os/repositories/contract_repository.dart';

class ContractFormScreen extends StatefulWidget {
  final Contract? contract; // Null untuk kontrak baru, non-null untuk edit

  const ContractFormScreen({
    super.key,
    this.contract,
  });

  @override
  State<ContractFormScreen> createState() => _ContractFormScreenState();
}

class _ContractFormScreenState extends State<ContractFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _projectValueController = TextEditingController();
  final ContractRepository _contractRepository = ContractRepository();
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.contract != null) {
      // Mode edit: isi form dengan data kontrak yang ada
      _clientNameController.text = widget.contract!.clientName;
      _projectValueController.text = widget.contract!.projectValue.toString();
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _projectValueController.dispose();
    super.dispose();
  }

  Future<void> _saveContract() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (!_authRepository.isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda harus login terlebih dahulu')),
          );
          return;
        }

        final clientName = _clientNameController.text;
        final projectValue = double.parse(_projectValueController.text.replaceAll(',', '.'));

        if (widget.contract == null) {
          // Membuat kontrak baru
          await _contractRepository.addContract(clientName, projectValue);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kontrak berhasil dibuat')),
            );
            Navigator.pop(context, true); // Kembali dengan hasil sukses
          }
        } else {
          // Memperbarui kontrak yang ada
          await _contractRepository.updateContract(
            widget.contract!.id,
            clientName,
            projectValue,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kontrak berhasil diperbarui')),
            );
            Navigator.pop(context, true); // Kembali dengan hasil sukses
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contract != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Kontrak' : 'Tambah Kontrak'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama klien tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _projectValueController,
                decoration: const InputDecoration(
                  labelText: 'Nilai Proyek',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nilai proyek tidak boleh kosong';
                  }
                  try {
                    double.parse(value.replaceAll(',', '.'));
                  } catch (e) {
                    return 'Format nilai proyek tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveContract,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(isEditing ? 'Perbarui' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:freelancer_os/models/contract.dart';
import 'package:freelancer_os/services/supabase_service.dart';
import 'package:intl/intl.dart';

class ContractsScreen extends StatefulWidget {
  const ContractsScreen({super.key});

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrak'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<List<Contract>>(
        stream: SupabaseService.streamContracts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final contracts = snapshot.data ?? [];

          if (contracts.isEmpty) {
            return const Center(
              child: Text('Belum ada kontrak. Buat kontrak baru untuk memulai.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              final contract = contracts[index];
              return _buildContractCard(contract);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddContractDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContractCard(Contract contract) {
    final statusColor = _getStatusColor(contract.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(
                    _getStatusText(contract.status),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Klien: ${contract.clientName}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Nilai Proyek: ${_currencyFormat.format(contract.projectValue)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('dd MMM yyyy').format(contract.startDate)} - ${DateFormat('dd MMM yyyy').format(contract.endDate)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  onPressed: () {
                    _showEditContractDialog(context, contract);
                  },
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    _confirmDeleteContract(context, contract);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Draft';
      case 'aktif':
      case 'active':
        return 'Aktif';
      case 'selesai':
      case 'completed':
        return 'Selesai';
      case 'dibatalkan':
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'aktif':
      case 'active':
        return Colors.green;
      case 'selesai':
      case 'completed':
        return Colors.blue;
      case 'dibatalkan':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showAddContractDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String clientName = '';
    String projectName = '';
    double projectValue = 0;
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kontrak Baru'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nama Klien',
                    icon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama klien tidak boleh kosong';
                    }
                    return null;
                  },
                  onSaved: (value) => clientName = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nama Proyek',
                    icon: Icon(Icons.work),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama proyek tidak boleh kosong';
                    }
                    return null;
                  },
                  onSaved: (value) => projectName = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nilai Proyek',
                    icon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nilai proyek tidak boleh kosong';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                  onSaved: (value) => projectValue = double.parse(value!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 16),
                    const Text('Tanggal Mulai:'),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (selected != null) {
                          setState(() {
                            startDate = selected;
                          });
                        }
                      },
                      child: Text(DateFormat('dd MMM yyyy').format(startDate)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 16),
                    const Text('Tanggal Selesai:'),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (selected != null) {
                          setState(() {
                            endDate = selected;
                          });
                        }
                      },
                      child: Text(DateFormat('dd MMM yyyy').format(endDate)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                
                try {
                  final userId = SupabaseService.currentUser?.id;
                  if (userId == null) {
                    throw Exception('User tidak terautentikasi');
                  }
                  
                  final contract = Contract(
                    userId: userId,
                    clientName: clientName,
                    projectName: projectName,
                    projectValue: projectValue,
                    startDate: startDate,
                    endDate: endDate,
                    status: 'draft',
                  );
                  
                  await SupabaseService.addContract(contract);
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditContractDialog(BuildContext context, Contract contract) async {
    final formKey = GlobalKey<FormState>();
    String clientName = contract.clientName;
    String projectName = contract.projectName;
    double projectValue = contract.projectValue;
    DateTime startDate = contract.startDate;
    DateTime endDate = contract.endDate;
    String status = contract.status;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Kontrak'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nama Klien',
                    icon: Icon(Icons.person),
                  ),
                  initialValue: clientName,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama klien tidak boleh kosong';
                    }
                    return null;
                  },
                  onSaved: (value) => clientName = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nama Proyek',
                    icon: Icon(Icons.work),
                  ),
                  initialValue: projectName,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama proyek tidak boleh kosong';
                    }
                    return null;
                  },
                  onSaved: (value) => projectName = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nilai Proyek',
                    icon: Icon(Icons.attach_money),
                  ),
                  initialValue: projectValue.toString(),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nilai proyek tidak boleh kosong';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                  onSaved: (value) => projectValue = double.parse(value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    icon: Icon(Icons.flag),
                  ),
                  value: status,
                  items: const [
                    DropdownMenuItem(value: 'draft', child: Text('Draft')),
                    DropdownMenuItem(value: 'active', child: Text('Aktif')),
                    DropdownMenuItem(value: 'completed', child: Text('Selesai')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Dibatalkan')),
                  ],
                  onChanged: (value) {
                    status = value!;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 16),
                    const Text('Tanggal Mulai:'),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (selected != null) {
                          setState(() {
                            startDate = selected;
                          });
                        }
                      },
                      child: Text(DateFormat('dd MMM yyyy').format(startDate)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 16),
                    const Text('Tanggal Selesai:'),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (selected != null) {
                          setState(() {
                            endDate = selected;
                          });
                        }
                      },
                      child: Text(DateFormat('dd MMM yyyy').format(endDate)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                
                try {
                  final updatedContract = contract.copyWith(
                    clientName: clientName,
                    projectName: projectName,
                    projectValue: projectValue,
                    startDate: startDate,
                    endDate: endDate,
                    status: status,
                    updatedAt: DateTime.now(),
                  );
                  
                  await SupabaseService.updateContract(updatedContract);
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteContract(BuildContext context, Contract contract) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kontrak'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus kontrak ini? Tindakan ini tidak dapat dibatalkan.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await SupabaseService.deleteContract(contract.id!);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
} 
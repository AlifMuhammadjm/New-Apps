import 'package:flutter/material.dart';
import 'package:freelancer_os/models/contract_model.dart';
import 'package:freelancer_os/repositories/auth_repository.dart';
import 'package:freelancer_os/repositories/contract_repository.dart';
import 'package:freelancer_os/screens/auth/login_screen.dart';
import 'package:freelancer_os/screens/contract_form_screen.dart';

class ContractListScreen extends StatefulWidget {
  const ContractListScreen({super.key});

  @override
  State<ContractListScreen> createState() => _ContractListScreenState();
}

class _ContractListScreenState extends State<ContractListScreen> {
  final ContractRepository _contractRepository = ContractRepository();
  final AuthRepository _authRepository = AuthRepository();
  late Future<List<Contract>> _contractsFuture;
  
  @override
  void initState() {
    super.initState();
    _loadContracts();
  }
  
  void _loadContracts() {
    if (_authRepository.isAuthenticated) {
      _contractsFuture = _contractRepository.getContracts();
    } else {
      _contractsFuture = Future.value([]);
      // Redirect ke login jika belum login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    }
  }

  Future<void> _navigateToContractForm({Contract? contract}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContractFormScreen(contract: contract),
      ),
    );

    if (result == true) {
      // Refresh daftar kontrak jika ada perubahan
      setState(() {
        _loadContracts();
      });
    }
  }

  Future<void> _deleteContract(String contractId) async {
    try {
      await _contractRepository.deleteContract(contractId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kontrak berhasil dihapus')),
      );
      setState(() {
        _loadContracts();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await _authRepository.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kontrak'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<List<Contract>>(
        future: _contractsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Tidak ada kontrak yang ditemukan'),
            );
          } else {
            final contracts = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _loadContracts();
                });
              },
              child: ListView.builder(
                itemCount: contracts.length,
                itemBuilder: (context, index) {
                  final contract = contracts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(contract.clientName),
                      subtitle: Text(
                        'Nilai Proyek: Rp ${contract.projectValue.toStringAsFixed(0)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${contract.createdAt.day}/${contract.createdAt.month}/${contract.createdAt.year}',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _navigateToContractForm(contract: contract),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Konfirmasi'),
                                  content: const Text('Yakin ingin menghapus kontrak ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteContract(contract.id);
                                      },
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () => _navigateToContractForm(contract: contract),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToContractForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 
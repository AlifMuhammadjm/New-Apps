import 'package:flutter/material.dart';
import 'package:freelancer_os/models/contract_model.dart';
import 'package:freelancer_os/repositories/auth_repository.dart';
import 'package:freelancer_os/repositories/contract_repository.dart';
import 'package:freelancer_os/screens/auth/login_page.dart';
import 'package:freelancer_os/screens/contract_form_screen.dart';
import 'package:freelancer_os/screens/payment/payment_history_screen.dart';
import 'package:freelancer_os/screens/payment/payment_screen.dart';

class ContractsPage extends StatefulWidget {
  const ContractsPage({super.key});

  @override
  State<ContractsPage> createState() => _ContractsPageState();
}

class _ContractsPageState extends State<ContractsPage> {
  final ContractRepository _contractRepository = ContractRepository();
  final AuthRepository _authRepository = AuthRepository();
  
  @override
  void initState() {
    super.initState();
    
    // Cek autentikasi dan redirect ke login jika belum login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_authRepository.isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
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
      setState(() {});
    }
  }

  Future<void> _navigateToPaymentScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentScreen(),
      ),
    );
  }

  Future<void> _navigateToPaymentHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentHistoryScreen(),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await _authRepository.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
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
            icon: const Icon(Icons.payment),
            onPressed: _navigateToPaymentHistory,
            tooltip: 'Riwayat Pembayaran',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner layanan premium
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.amber.shade100,
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Upgrade ke layanan premium untuk fitur tambahan!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: _navigateToPaymentScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Upgrade'),
                ),
              ],
            ),
          ),
          // Daftar kontrak
          Expanded(
            child: FutureBuilder<List<Contract>>(
              future: _contractRepository.getContracts(),
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
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final contract = snapshot.data![index];
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
                            ],
                          ),
                          onTap: () => _navigateToContractForm(contract: contract),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToContractForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 
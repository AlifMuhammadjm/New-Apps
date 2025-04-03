import 'package:flutter/material.dart';
import 'package:freelancer_os/screens/add_contract_screen.dart';
import 'package:freelancer_os/screens/generate_contract_screen.dart';
import 'package:freelancer_os/screens/subscription_screen.dart';
import 'package:freelancer_os/screens/payment_screen.dart';
import 'package:freelancer_os/screens/contracts_screen.dart';
import 'package:freelancer_os/screens/financial_report_screen.dart';
import 'package:freelancer_os/screens/settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Freelancer OS'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.subscriptions),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
              );
            },
            tooltip: 'Langganan',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Freelancer OS',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kelola Bisnis Freelance Anda',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Kontrak'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContractsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Laporan Keuangan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FinancialReportScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat Datang di Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ringkasan Aktivitas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    'Kontrak Aktif',
                    '3',
                    Icons.assignment,
                    Colors.blue,
                    context,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContractsScreen()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    'Invoice Tertunda',
                    '2',
                    Icons.receipt,
                    Colors.orange,
                    context,
                    onTap: () {
                      // Navigasi ke halaman invoice
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur invoice akan segera hadir')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    'Jam Tercatat',
                    '24.5',
                    Icons.schedule,
                    Colors.green,
                    context,
                    onTap: () {
                      // Navigasi ke halaman pelacakan waktu
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur pelacakan waktu akan segera hadir')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    'Pendapatan Bulan Ini',
                    'Rp 5.250.000',
                    Icons.monetization_on,
                    Colors.purple,
                    context,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FinancialReportScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman tambah kontrak
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddContractScreen()),
          ).then((value) {
            // Refresh dashboard jika kontrak berhasil ditambahkan
            if (value == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kontrak telah ditambahkan. Dashboard akan diperbarui.')),
              );
              // Di sini Anda bisa menambahkan logika untuk refresh data
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
    BuildContext context, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
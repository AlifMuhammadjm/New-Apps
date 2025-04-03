import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/auth_repository.dart';
import '../repositories/contract_repository.dart';
import '../repositories/invoice_repository.dart';
import '../services/notification_service.dart';
import '../services/contract_service.dart';
import '../services/client_service.dart';
import 'contracts_screen.dart';
import 'clients_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final ContractService _contractService = ContractService();
  final ClientService _clientService = ClientService();
  final NotificationService _notificationService = NotificationService();
  
  int _selectedIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Freelancer OS'),
      ),
      drawer: _buildNavigationDrawer(context),
      body: _buildDashboardBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Kontrak',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Faktur',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index != 0) {
            _showFeatureUnderDevelopment(context, 'Fitur pada menu bawah');
          }
        },
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Freelancer Demo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'freelancer@example.com',
                  style: TextStyle(
                    color: Colors.white70,
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
                MaterialPageRoute(builder: (context) => const ContractsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Klien'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClientsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Faktur'),
            onTap: () {
              Navigator.pop(context);
              _showFeatureUnderDevelopment(context, 'Halaman faktur');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Pengaturan'),
            onTap: () {
              Navigator.pop(context);
              _showFeatureUnderDevelopment(context, 'Pengaturan');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Keluar'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardBody() {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    
    final totalActiveContractsValue = _contractService.getTotalActiveContractsValue();
    final activeContractsCount = _contractService.getContractCountByStatus('active');
    final completedContractsCount = _contractService.getContractCountByStatus('completed');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat Datang, Freelancer!',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Anda memiliki $activeContractsCount kontrak aktif senilai ${currencyFormat.format(totalActiveContractsValue)}',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          const Text(
            'Ringkasan Aktivitas',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildDashboardCard(
                icon: Icons.description,
                iconColor: Colors.blue,
                title: 'Kontrak Aktif',
                value: activeContractsCount.toString(),
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const ContractsScreen())
                  );
                },
              ),
              _buildDashboardCard(
                icon: Icons.check_circle,
                iconColor: Colors.green,
                title: 'Kontrak Selesai',
                value: completedContractsCount.toString(),
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const ContractsScreen())
                  );
                },
              ),
              _buildDashboardCard(
                icon: Icons.receipt,
                iconColor: Colors.orange,
                title: 'Faktur Tertunda',
                value: '3',
                onTap: () {
                  _showFeatureUnderDevelopment(context, 'Faktur tertunda');
                },
              ),
              _buildDashboardCard(
                icon: Icons.people,
                iconColor: Colors.purple,
                title: 'Klien',
                value: _clientService.getTotalClientsCount().toString(),
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const ClientsScreen())
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          Card(
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pendapatan Bulan Ini',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    currencyFormat.format(5500000),
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const LinearProgressIndicator(
                    value: 0.7,
                    minHeight: 10.0,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    '70% dari target bulan ini',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 30.0,
              ),
              const SizedBox(height: 8.0),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeatureUnderDevelopment(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature sedang dalam pengembangan'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 
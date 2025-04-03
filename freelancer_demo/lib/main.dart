import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'firebase_options.dart';
import 'screens/contracts_screen.dart';
import 'screens/direct_login_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/subscription_screen.dart';
import 'services/notification_service.dart';
import 'services/contract_service.dart';
import 'services/client_service.dart';
import 'repositories/auth_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Konfigurasi handler error global
  ErrorWidget.builder = (FlutterErrorDetails error) {
    return Scaffold(
      body: Center(child: Text('Terjadi error: ${error.exception.toString()}')),
    );
  };

  // Konfigurasi Supabase - Anda harus mengganti dengan kredensial Supabase Anda sendiri
  await Supabase.initialize(
    url: 'https://esdgcmyfwzhnhbhqwriq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVzZGdjbXlmd3pobmhiaHF3cmlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2NDc3NjYsImV4cCI6MjA1OTIyMzc2Nn0.-DQZNWPYPHLdNft4CuYd65qF1IQ3SiyXgvb2qdnR26I',
    debug: kDebugMode,
    authFlowType: AuthFlowType.pkce,
    authCallbackUrlHostname: 'login-callback',
  );
  debugPrint('***** Supabase init completed ${Supabase.instance}');

  // Inisialisasi Intl untuk format bahasa Indonesia
  Intl.defaultLocale = 'id_ID';

  // Inisialisasi NotificationService
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _authRepository = AuthRepository();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupAuthStateListener();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  void _setupAuthStateListener() {
    _authRepository.authStateChanges.listen((event) {
      // Perbarui UI ketika status autentikasi berubah
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreelanceGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      locale: const Locale('id', 'ID'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      home: _authRepository.isLoggedIn ? const DashboardScreen() : const DirectLoginScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ContractService _contractService = ContractService();
  final ClientService _clientService = ClientService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FreelanceGuard'),
      ),
      drawer: _buildNavigationDrawer(context),
      body: _buildDashboardBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
        ],
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
                  'FreelanceGuard Demo',
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
          ListTile(
            leading: const Icon(Icons.card_membership),
            title: const Text('Langganan Premium'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
          ),
          const Divider(),
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
                          MaterialPageRoute(builder: (context) => const DirectLoginScreen()),
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

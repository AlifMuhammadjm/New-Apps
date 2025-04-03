import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'package:freelancer_os/services/supabase_service.dart';
import 'package:freelancer_os/services/paypal_service.dart';
import 'package:google_fonts/google_fonts.dart';

// Kelas sederhana sebagai pengganti OpenAIService
class OpenAIService {
  Future<void> initialize() async {
    // Tidak melakukan apa-apa untuk saat ini
    print('OpenAI Service diinisialisasi (dummy)');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Supabase
  await SupabaseService.initialize(
    supabaseUrl: 'https://esdgcmyfwzhnhbhqwriq.supabase.co',
    supabaseKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVzZGdjbXlmd3pobmhiaHF3cmlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2NDc3NjYsImV4cCI6MjA1OTIyMzc2Nn0.-DQZNWPYPHLdNft4CuYd65qF1IQ3SiyXgvb2qdnR26I',
  );
  
  // Inisialisasi layanan lainnya
  final openAIService = OpenAIService();
  await openAIService.initialize();
  
  final paypalService = PayPalService();
  await paypalService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freelancer OS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Freelancer OS'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selamat datang di Freelancer OS',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aplikasi untuk mengelola proyek dan keuangan freelancer',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Fitur yang tersedia:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(Icons.assignment, 'Manajemen Kontrak'),
                    _buildFeatureItem(Icons.credit_card, 'Pembayaran dengan PayPal'),
                    _buildFeatureItem(Icons.schedule, 'Pelacakan Waktu'),
                    _buildFeatureItem(Icons.receipt, 'Pembuatan Invoice'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman dashboard
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Mulai Sekarang', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

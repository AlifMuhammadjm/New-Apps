import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freelancer_os/services/supabase_setup.dart';
import 'package:freelancer_os/services/supabase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoadingRLSStatus = false;
  final Map<String, bool> _rlsStatus = {
    'contracts': false,
    'invoices': false,
    'subscriptions': false,
  };

  @override
  void initState() {
    super.initState();
    _checkRLSStatus();
  }

  Future<void> _checkRLSStatus() async {
    setState(() {
      _isLoadingRLSStatus = true;
    });

    try {
      for (final table in _rlsStatus.keys) {
        final status = await SupabaseSetup.checkRLSStatus(table);
        setState(() {
          _rlsStatus[table] = status;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoadingRLSStatus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Keamanan Supabase',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Status Pengaturan Row Level Security (RLS) dan kebijakan akses untuk tabel-tabel di Supabase',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status Keamanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isLoadingRLSStatus)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _checkRLSStatus,
                            tooltip: 'Refresh',
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildRLSStatusItem('contracts', 'Kontrak'),
                    const Divider(),
                    _buildRLSStatusItem('invoices', 'Invoice'),
                    const Divider(),
                    _buildRLSStatusItem('subscriptions', 'Langganan'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                SupabaseSetup.showSetupInstructions(context);
              },
              icon: const Icon(Icons.code),
              label: const Text('Lihat SQL Setup'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Koneksi Supabase',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSubabaseInfoSection(),
            const SizedBox(height: 24),
            const Text(
              'Fungsi execute_sql',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fungsi execute_sql digunakan untuk menjalankan SQL kustom dengan keamanan yang tetap terjaga. Pastikan fungsi ini telah dibuat dan diberikan akses kepada pengguna yang terotentikasi.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Contoh Penggunaan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(
                              text: '''
SELECT SUM(project_value) as total
FROM contracts
WHERE user_id = auth.uid()
AND created_at >= '2024-01-01'
''',
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('SQL disalin ke clipboard')),
                            );
                          },
                          tooltip: 'Salin ke clipboard',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const SelectableText('''
SELECT SUM(project_value) as total
FROM contracts
WHERE user_id = auth.uid()
AND created_at >= '2024-01-01'
'''),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRLSStatusItem(String tableName, String displayName) {
    final isEnabled = _rlsStatus[tableName] ?? false;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Tabel: $tableName',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          isEnabled
              ? const Chip(
                  label: Text('RLS Aktif'),
                  backgroundColor: Colors.green,
                  labelStyle: TextStyle(color: Colors.white),
                )
              : const Chip(
                  label: Text('RLS Tidak Aktif'),
                  backgroundColor: Colors.red,
                  labelStyle: TextStyle(color: Colors.white),
                ),
        ],
      ),
    );
  }

  Widget _buildSubabaseInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konfigurasi Supabase',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Untuk mengatur koneksi Supabase, perbarui nilai berikut di file main.dart:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const SelectableText('''
await SupabaseService.initialize(
  supabaseUrl: 'YOUR_SUPABASE_URL',
  supabaseKey: 'YOUR_SUPABASE_ANON_KEY',
);
'''),
            const SizedBox(height: 16),
            const Text(
              'Konfigurasi ini memastikan aplikasi terhubung dengan benar ke proyek Supabase Anda.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
} 
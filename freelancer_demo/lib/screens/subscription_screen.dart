import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/payment_methods_widget.dart';
import '../services/notification_service.dart';

/// Screen untuk berlangganan layanan FreelanceGuard Premium
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final NotificationService _notificationService = NotificationService();
  
  // Paket langganan yang tersedia
  final List<Map<String, dynamic>> _subscriptionPlans = [
    {
      'id': 'basic',
      'name': 'Basic',
      'price': 99000,
      'currency': 'IDR',
      'period': 'bulan',
      'features': [
        'Manajemen kontrak (max 5)',
        'Manajemen klien (max 5)',
        'Pembuatan faktur dasar',
        'PDF generator',
      ],
      'color': Colors.green,
      'recommended': false,
    },
    {
      'id': 'pro',
      'name': 'Professional',
      'price': 199000,
      'currency': 'IDR',
      'period': 'bulan',
      'features': [
        'Manajemen kontrak (unlimited)',
        'Manajemen klien (unlimited)',
        'Pembuatan faktur lengkap',
        'PDF generator',
        'Escrow payments',
        'Integrasi kalender',
        'Dukungan prioritas',
      ],
      'color': Colors.blue,
      'recommended': true,
    },
    {
      'id': 'business',
      'name': 'Business',
      'price': 499000,
      'currency': 'IDR',
      'period': 'bulan',
      'features': [
        'Semua fitur Professional',
        'Multi-user (5 akun)',
        'Analitik bisnis',
        'Laporan keuangan',
        'Manajemen proyek',
        'Pelacakan waktu',
        'API akses',
        'Dukungan premium 24/7',
      ],
      'color': Colors.purple,
      'recommended': false,
    },
  ];
  
  Map<String, dynamic>? _selectedPlan;
  bool _showPaymentMethods = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Subscription'),
      ),
      body: _showPaymentMethods
          ? _buildPaymentMethodsSection()
          : _buildSubscriptionPlansSection(),
    );
  }
  
  // Bagian pilihan paket langganan
  Widget _buildSubscriptionPlansSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Pilih Paket Berlangganan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tingkatkan bisnis freelance Anda dengan fitur premium',
            style: TextStyle(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _subscriptionPlans.length,
              itemBuilder: (context, index) {
                final plan = _subscriptionPlans[index];
                return _buildSubscriptionPlanCard(plan);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // Kartu paket langganan
  Widget _buildSubscriptionPlanCard(Map<String, dynamic> plan) {
    final isSelected = _selectedPlan != null && _selectedPlan!['id'] == plan['id'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: plan['color'], width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan['name'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: plan['color'],
                  ),
                ),
                if (plan['recommended'])
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: plan['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Recommended',
                      style: TextStyle(
                        fontSize: 12,
                        color: plan['color'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp ${plan['price']}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '/${plan['period']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...plan['features'].map<Widget>((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: plan['color'],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(feature),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _selectPlan(plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: plan['color'],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Pilih Paket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Bagian pilihan metode pembayaran
  Widget _buildPaymentMethodsSection() {
    if (_selectedPlan == null) {
      return const Center(child: Text('Silahkan pilih paket langganan terlebih dahulu'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _showPaymentMethods = false;
                  });
                },
              ),
              const Text(
                'Pembayaran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Ringkasan Pembelian
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Pembelian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    'Paket',
                    _selectedPlan!['name'],
                  ),
                  _buildSummaryRow(
                    'Periode',
                    '1 ${_selectedPlan!['period']}',
                  ),
                  _buildSummaryRow(
                    'Harga',
                    'Rp ${_selectedPlan!['price']}',
                  ),
                  const Divider(),
                  _buildSummaryRow(
                    'Total',
                    'Rp ${_selectedPlan!['price']}',
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          
          // Payment Methods
          PaymentMethodsWidget(
            amount: _selectedPlan!['price'].toDouble(),
            currency: _selectedPlan!['currency'],
            description: 'FreelanceGuard ${_selectedPlan!['name']} Subscription',
            onPaymentSuccess: _handlePaymentSuccess,
          ),
        ],
      ),
    );
  }
  
  // Baris untuk ringkasan pembayaran
  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  // Memilih paket langganan
  void _selectPlan(Map<String, dynamic> plan) {
    setState(() {
      _selectedPlan = plan;
      _showPaymentMethods = true;
    });
  }
  
  // Handle ketika pembayaran berhasil
  void _handlePaymentSuccess(String transactionId) {
    _notificationService.showFlutterToast(
      'Pembayaran berhasil dengan ID: $transactionId',
    );
    
    // Kembali ke halaman utama setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop(true); // true menandakan pembayaran berhasil
      }
    });
  }
} 
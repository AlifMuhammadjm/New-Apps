import 'package:flutter/material.dart';
import 'package:freelancer_os/models/subscription_model.dart';
import 'package:freelancer_os/services/supabase_service.dart';
import 'package:freelancer_os/screens/payment_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = true;
  Subscription? _activeSubscription;
  final String _userId = '123'; // Placeholder untuk contoh

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = SupabaseService();
      final subscriptionData = await supabaseService.getActiveSubscription(
        userId: _userId,
      );

      setState(() {
        _activeSubscription = subscriptionData != null
            ? Subscription.fromMap(subscriptionData)
            : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _goToPayment(String plan, double amount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          amount: amount,
          description: 'Langganan $plan untuk Freelancer OS',
          onPaymentComplete: (success) {
            if (success) {
              _createSubscription(plan);
            }
          },
        ),
      ),
    );
  }

  Future<void> _createSubscription(String plan) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = SupabaseService();
      
      // Hitung tanggal berakhir (1 bulan dari sekarang)
      final now = DateTime.now();
      final endDate = DateTime(now.year, now.month + 1, now.day);
      
      await supabaseService.createSubscription(
        userId: _userId,
        plan: plan,
        startDate: now,
        endDate: endDate,
      );

      // Refresh data langganan
      await _loadSubscription();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Langganan berhasil diaktifkan')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _cancelSubscription() async {
    if (_activeSubscription?.id == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = SupabaseService();
      
      await supabaseService.cancelSubscription(
        subscriptionId: _activeSubscription!.id!,
      );

      // Refresh data langganan
      await _loadSubscription();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Langganan berhasil dibatalkan')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Langganan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_activeSubscription != null) ...[
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Langganan Aktif',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    _activeSubscription!.plan.toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.blue,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('Status: ${_activeSubscription!.status}'),
                            const SizedBox(height: 8),
                            Text(
                              'Tanggal Mulai: ${_activeSubscription!.startDate.day}/${_activeSubscription!.startDate.month}/${_activeSubscription!.startDate.year}',
                            ),
                            if (_activeSubscription!.endDate != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Tanggal Berakhir: ${_activeSubscription!.endDate!.day}/${_activeSubscription!.endDate!.month}/${_activeSubscription!.endDate!.year}',
                              ),
                            ],
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _cancelSubscription,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Batalkan Langganan'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Upgrade Langganan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Pilih Paket Langganan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tingkatkan produktivitas Anda dengan berbagai fitur premium',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildSubscriptionCard(
                    title: 'Free',
                    price: 'Rp 0',
                    features: [
                      'Manajemen 3 kontrak aktif',
                      'Invoice dasar',
                      'Akses ke templat kontrak dasar',
                    ],
                    isRecommended: false,
                    onSubscribe: () {
                      // Langganan gratis, langsung aktifkan
                      _createSubscription('free');
                    },
                    buttonText: _activeSubscription?.isFree == true
                        ? 'Paket Saat Ini'
                        : 'Pilih Paket',
                    isCurrentPlan: _activeSubscription?.isFree == true,
                  ),
                  const SizedBox(height: 16),
                  _buildSubscriptionCard(
                    title: 'Pro',
                    price: 'Rp 99.000/bulan',
                    features: [
                      'Manajemen kontrak tidak terbatas',
                      'Invoice premium',
                      'Templat kontrak AI',
                      'Pelacakan waktu proyek',
                    ],
                    isRecommended: true,
                    onSubscribe: () {
                      _goToPayment('Pro', 12.0); // $12 USD
                    },
                    buttonText: _activeSubscription?.isPro == true
                        ? 'Paket Saat Ini'
                        : 'Pilih Paket',
                    isCurrentPlan: _activeSubscription?.isPro == true,
                  ),
                  const SizedBox(height: 16),
                  _buildSubscriptionCard(
                    title: 'Premium',
                    price: 'Rp 199.000/bulan',
                    features: [
                      'Semua fitur Pro',
                      'Integrasi PayPal',
                      'CRM klien lengkap',
                      'Analisis bisnis',
                      'Support prioritas',
                    ],
                    isRecommended: false,
                    onSubscribe: () {
                      _goToPayment('Premium', 24.0); // $24 USD
                    },
                    buttonText: _activeSubscription?.isPremium == true
                        ? 'Paket Saat Ini'
                        : 'Pilih Paket',
                    isCurrentPlan: _activeSubscription?.isPremium == true,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSubscriptionCard({
    required String title,
    required String price,
    required List<String> features,
    required bool isRecommended,
    required VoidCallback onSubscribe,
    required String buttonText,
    required bool isCurrentPlan,
  }) {
    return Card(
      elevation: isRecommended ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRecommended
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Chip(
                label: const Text(
                  'Rekomendasi',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(feature)),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCurrentPlan ? null : onSubscribe,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: isCurrentPlan
                      ? Colors.grey.shade300
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor:
                      isCurrentPlan ? Colors.black54 : Colors.white,
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
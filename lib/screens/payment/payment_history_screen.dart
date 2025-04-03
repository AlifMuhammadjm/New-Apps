import 'package:flutter/material.dart';
import 'package:freelancer_os/models/payment_model.dart';
import 'package:freelancer_os/repositories/auth_repository.dart';
import 'package:freelancer_os/repositories/payment_repository.dart';
import 'package:freelancer_os/screens/auth/login_page.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final PaymentRepository _paymentRepository = PaymentRepository();
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

  // Mendapatkan warna berdasarkan status pembayaran
  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Mendapatkan ikon berdasarkan provider pembayaran
  IconData _getProviderIcon(PaymentProvider provider) {
    switch (provider) {
      case PaymentProvider.paypal:
        return Icons.paypal;
      case PaymentProvider.stripe:
        return Icons.payment;
      case PaymentProvider.razorpay:
        return Icons.account_balance_wallet;
      default:
        return Icons.credit_card;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembayaran'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Payment>>(
        future: _paymentRepository.getPayments(),
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
              child: Text('Tidak ada riwayat pembayaran'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final payment = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Icon(
                      _getProviderIcon(payment.provider),
                      color: Theme.of(context).primaryColor,
                      size: 32,
                    ),
                    title: Text('\$${payment.amount.toStringAsFixed(2)}'),
                    subtitle: Row(
                      children: [
                        Text(
                          payment.provider.toString().split('.').last.toUpperCase(),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(payment.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            payment.status.toString().split('.').last.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(payment.status),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year}',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
} 
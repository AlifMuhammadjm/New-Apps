import 'package:flutter/material.dart';
import '../services/xendit_service.dart';
import '../services/notification_service.dart';
import 'dart:math' as math;

/// Widget untuk menampilkan metode pembayaran yang tersedia
class PaymentMethodsWidget extends StatefulWidget {
  final double amount;
  final String currency;
  final String description;
  final Function(String) onPaymentSuccess;

  const PaymentMethodsWidget({
    Key? key,
    required this.amount,
    required this.currency,
    required this.description,
    required this.onPaymentSuccess,
  }) : super(key: key);

  @override
  State<PaymentMethodsWidget> createState() => _PaymentMethodsWidgetState();
}

class _PaymentMethodsWidgetState extends State<PaymentMethodsWidget> with SingleTickerProviderStateMixin {
  final XenditService _xenditService = XenditService();
  final NotificationService _notificationService = NotificationService();
  
  String? _selectedBank;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Pilih Metode Pembayaran',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        
        // Kartu Credit/Debit option
        _buildCreditCardOption(),
        const SizedBox(height: 24),
        
        const Text(
          'atau',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        
        // Virtual Account option
        _buildVirtualAccountOption(),
      ],
    );
  }
  
  /// Build Credit/Debit Card payment option
  Widget _buildCreditCardOption() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 32,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _animationController.value * 2 * math.pi,
                        child: const Icon(
                          Icons.credit_card,
                          color: Colors.blue,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Kartu Kredit/Debit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Bayar dengan kartu kredit/debit Visa, Mastercard, atau JCB.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleCreditCardPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Bayar dengan Kartu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build Virtual Account payment option
  Widget _buildVirtualAccountOption() {
    final banks = _xenditService.supportedBanks;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance, color: Colors.green),
                const SizedBox(width: 12),
                const Text(
                  'Transfer Bank',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Bayar dengan transfer bank melalui Virtual Account.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Pilih Bank',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              value: _selectedBank,
              items: banks.map((bank) {
                return DropdownMenuItem<String>(
                  value: bank['code'],
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Color(bank['color']),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            bank['code'][0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(bank['name']),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBank = value;
                });
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedBank == null ? null : _handleVirtualAccountPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Buat Virtual Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Handle Credit Card payment
  void _handleCreditCardPayment() async {
    // Simulasi proses pembayaran kartu kredit
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memproses pembayaran dengan kartu...'),
          ],
        ),
      ),
    );
    
    // Simulasi delay untuk proses pembayaran
    await Future.delayed(const Duration(seconds: 2));
    
    // Tutup dialog loading
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    
    // Simulasi hasil pembayaran (sukses, gagal, atau batal)
    final random = math.Random().nextInt(10);
    
    if (random < 7) { // 70% chance of success
      final transactionId = 'CC-${DateTime.now().millisecondsSinceEpoch}';
      _notificationService.showFlutterToast('Pembayaran Kartu berhasil!');
      widget.onPaymentSuccess(transactionId);
    } else if (random < 9) { // 20% chance of error
      _notificationService.showFlutterToast(
        'Pembayaran gagal: Terjadi kesalahan saat memproses pembayaran.', 
        isError: true
      );
    } else { // 10% chance of cancellation
      _notificationService.showFlutterToast(
        'Pembayaran dibatalkan.', 
        isError: false
      );
    }
  }
  
  /// Handle Virtual Account payment
  void _handleVirtualAccountPayment() async {
    if (_selectedBank == null) {
      _notificationService.showFlutterToast(
        'Silakan pilih bank terlebih dahulu.',
        isError: true
      );
      return;
    }
    
    // Simulasi proses pembuatan virtual account
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Membuat virtual account...'),
          ],
        ),
      ),
    );
    
    // Simulasi delay untuk proses pembuatan virtual account
    await Future.delayed(const Duration(seconds: 2));
    
    // Tutup dialog loading
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    
    // Simulasi data virtual account
    final bankCode = _selectedBank!;
    final bank = _xenditService.supportedBanks.firstWhere(
      (bank) => bank['code'] == bankCode
    );
    
    final virtualAccountNumber = '${bankCode}${math.Random().nextInt(10000000) + 80000000}';
    final externalId = 'VA-${DateTime.now().millisecondsSinceEpoch}';
    
    // Tampilkan informasi virtual account
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Instruksi Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bank: ${bank['name']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'No. Virtual Account: $virtualAccountNumber',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Jumlah: ${widget.currency} ${widget.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Catatan Penting:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Virtual account aktif selama 24 jam\n'
                '• Pembayaran akan diproses otomatis\n'
                '• Mohon transfer sesuai jumlah yang tertera'
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onPaymentSuccess(externalId);
              },
              child: const Text('LANJUTKAN'),
            ),
          ],
        ),
      );
    }
  }
} 
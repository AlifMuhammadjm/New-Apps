import 'package:freelancer_os/models/payment_model.dart';
import 'package:freelancer_os/services/supabase_service.dart';
import 'package:paypal_payment/paypal_payment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentRepository {
  final SupabaseClient _supabase = SupabaseService().client;
  final String _tableName = 'payments';

  // Singleton pattern
  static final PaymentRepository _instance = PaymentRepository._internal();
  factory PaymentRepository() => _instance;
  PaymentRepository._internal();

  // Metode untuk pembayaran dengan PayPal
  Future<void> payWithPayPal({
    required double amount,
    required String description,
    String currency = "USD",
  }) async {
    try {
      if (!_supabase.auth.currentUser!.id.isNotEmpty) {
        throw Exception('Anda harus login terlebih dahulu');
      }

      final transaction = PayPalPayment(
        amount: amount.toString(),
        currency: currency,
        description: description,
      );

      await PayPalPayment().requestPayment(
        transaction,
        onSuccess: (data) async {
          try {
            // Menyimpan data pembayaran ke Supabase setelah pembayaran berhasil
            await _supabase.from(_tableName).insert({
              'user_id': _supabase.auth.currentUser!.id,
              'amount': amount,
              'provider': PaymentProvider.paypal.toString().split('.').last,
              'status': PaymentStatus.completed.toString().split('.').last,
            });
            print("Pembayaran berhasil: $data");
          } catch (e) {
            print("Error menyimpan data pembayaran: $e");
          }
        },
        onError: (error) {
          print("Error pembayaran: $error");
          throw Exception('Pembayaran gagal: $error');
        },
      );
    } catch (e) {
      throw Exception('Gagal memproses pembayaran: ${e.toString()}');
    }
  }

  // Mendapatkan semua pembayaran untuk pengguna saat ini
  Future<List<Payment>> getPayments() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Payment.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data pembayaran: ${e.toString()}');
    }
  }

  // Menambahkan pembayaran baru ke database
  Future<Payment> addPayment({
    required double amount,
    required PaymentProvider provider,
    required PaymentStatus status,
  }) async {
    try {
      final data = {
        'user_id': _supabase.auth.currentUser!.id,
        'amount': amount,
        'provider': provider.toString().split('.').last,
        'status': status.toString().split('.').last,
      };
      
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();
      
      return Payment.fromJson(response);
    } catch (e) {
      throw Exception('Gagal menambahkan pembayaran: ${e.toString()}');
    }
  }

  // Memperbarui status pembayaran
  Future<Payment> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
  }) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update({'status': status.toString().split('.').last})
          .eq('id', paymentId)
          .eq('user_id', _supabase.auth.currentUser!.id)
          .select()
          .single();
      
      return Payment.fromJson(response);
    } catch (e) {
      throw Exception('Gagal memperbarui status pembayaran: ${e.toString()}');
    }
  }
} 
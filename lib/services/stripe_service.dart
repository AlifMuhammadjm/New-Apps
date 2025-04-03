import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  // Singleton pattern
  static final StripeService _instance = StripeService._internal();
  
  factory StripeService() {
    return _instance;
  }
  
  StripeService._internal();
  
  String? _publishableKey;
  String? _secretKey;
  String? _baseUrl;
  
  Future<void> initialize({
    required String publishableKey,
    required String secretKey,
  }) async {
    _publishableKey = publishableKey;
    _secretKey = secretKey;
    _baseUrl = 'https://api.stripe.com/v1';
    
    // Initialize Stripe SDK
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }
  
  // Create payment intent
  Future<Map<String, dynamic>> createPaymentIntent({
    required String amount,
    required String currency,
    String? customerId,
    String? description,
  }) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      
      if (customerId != null) {
        body['customer'] = customerId;
      }
      
      if (description != null) {
        body['description'] = description;
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }
  
  // Process payment with card
  Future<PaymentIntentResult> processPayment({
    required String paymentIntentClientSecret,
  }) async {
    try {
      // Confirm the payment with the card
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntentClientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      
      return paymentIntent;
    } catch (e) {
      throw Exception('Error processing payment: $e');
    }
  }
  
  // Create customer
  Future<Map<String, dynamic>> createCustomer({
    required String email,
    String? name,
  }) async {
    try {
      Map<String, dynamic> body = {
        'email': email,
      };
      
      if (name != null) {
        body['name'] = name;
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/customers'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error creating customer: $e');
    }
  }
} 
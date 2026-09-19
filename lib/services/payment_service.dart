import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../core/constants/razorpay_config.dart';
import '../core/errors/app_exceptions.dart';

class PaymentCalculation {
  final double totalAmount;
  final double platformFee; // 5% PYP platform fee
  final double photographerAmount; // 95%

  const PaymentCalculation({
    required this.totalAmount,
    required this.platformFee,
    required this.photographerAmount,
  });

  factory PaymentCalculation.fromTotal(double total) {
    final fee = (total * 0.05);
    final photographerPart = total - fee;
    return PaymentCalculation(
      totalAmount: total,
      platformFee: fee,
      photographerAmount: photographerPart,
    );
  }
}

abstract class PaymentService {
  PaymentCalculation calculateBreakdown(double totalAmount);

  Future<String> createRazorpayOrder({
    required String bookingId,
    required double amount,
    String currency = 'INR',
  });

  Future<bool> verifyPaymentSignature({
    required String orderId,
    required String paymentId,
    required String signature,
  });

  void openCheckout({
    required String orderId,
    required double amount,
    required String description,
    required String userEmail,
    required String userPhone,
    required String userName,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    required Function(ExternalWalletResponse) onExternalWallet,
  });

  void dispose();
}

class RazorpayPaymentServiceImpl implements PaymentService {
  Razorpay? _razorpay;

  @override
  PaymentCalculation calculateBreakdown(double totalAmount) {
    return PaymentCalculation.fromTotal(totalAmount);
  }

  @override
  Future<String> createRazorpayOrder({
    required String bookingId,
    required double amount,
    String currency = 'INR',
  }) async {
    try {
      final amountInPaise = (amount * 100).toInt();
      final authHeader = 'Basic ${base64Encode(utf8.encode('${RazorpayConfig.keyId}:${RazorpayConfig.keySecret}'))}';

      final response = await http.post(
        Uri.parse('https://api.razorpay.com/v1/orders'),
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amountInPaise,
          'currency': currency,
          'receipt': bookingId.isNotEmpty ? bookingId : 'rcpt_${DateTime.now().millisecondsSinceEpoch}',
          'notes': {
            'bookingId': bookingId,
            'app': 'PYP - Pick Your Photographer',
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'] as String;
      } else {
        throw AppException('Razorpay order creation failed: ${response.body}');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error connecting to Razorpay: $e');
    }
  }

  @override
  Future<bool> verifyPaymentSignature({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    return paymentId.isNotEmpty && orderId.isNotEmpty;
  }

  @override
  void openCheckout({
    required String orderId,
    required double amount,
    required String description,
    required String userEmail,
    required String userPhone,
    required String userName,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _razorpay?.clear();
    _razorpay = Razorpay();

    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);

    final amountInPaise = (amount * 100).toInt();

    final options = {
      'key': RazorpayConfig.keyId,
      'amount': amountInPaise,
      'name': RazorpayConfig.merchantName,
      'description': description,
      'order_id': orderId,
      'prefill': {
        'contact': userPhone.isNotEmpty ? userPhone : '9999999999',
        'email': userEmail.isNotEmpty ? userEmail : 'user@pyp.app',
        'name': userName.isNotEmpty ? userName : 'PYP Client',
      },
      'theme': {
        'color': '#0F172A',
      },
      'modal': {
        'confirm_close': true,
      },
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      throw AppException('Failed to open Razorpay checkout: $e');
    }
  }

  @override
  void dispose() {
    _razorpay?.clear();
  }
}

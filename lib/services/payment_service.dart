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
    required String currency,
  });

  Future<bool> verifyPaymentSignature({
    required String orderId,
    required String paymentId,
    required String signature,
  });
}

class RazorpayPaymentServiceImpl implements PaymentService {
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
    // SECURITY REQUIREMENT:
    // Razorpay orders MUST be created via a trusted Cloud Function / backend server.
    // Never store Razorpay Key Secret in client Flutter code.
    throw const AppException(
      'Razorpay order creation must be routed through Firebase Cloud Functions to protect credentials.',
      code: 'UNCONFIGURED_BACKEND_PAYMENT',
    );
  }

  @override
  Future<bool> verifyPaymentSignature({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    // SECURITY REQUIREMENT:
    // Payment signature verification must be executed server-side to prevent fake client verification.
    throw const AppException(
      'Razorpay signature verification must be executed via Firebase Cloud Functions.',
      code: 'UNCONFIGURED_BACKEND_PAYMENT',
    );
  }
}

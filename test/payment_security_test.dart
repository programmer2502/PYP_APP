import 'package:flutter_test/flutter_test.dart';
import 'package:pyp_app/core/errors/app_exceptions.dart';
import 'package:pyp_app/services/payment_service.dart';

void main() {
  group('Phase 9 - Payment Boundary & Security Verification', () {
    test('5% PYP Platform Fee and Photographer Breakdown Calculations', () {
      // Test 1: ₹10,000 booking
      final calc1 = PaymentCalculation.fromTotal(10000.0);
      expect(calc1.totalAmount, 10000.0);
      expect(calc1.platformFee, 500.0); // 5% fee
      expect(calc1.photographerAmount, 9500.0); // 95% payout

      // Test 2: ₹8,000 booking
      final calc2 = PaymentCalculation.fromTotal(8000.0);
      expect(calc2.totalAmount, 8000.0);
      expect(calc2.platformFee, 400.0);
      expect(calc2.photographerAmount, 7600.0);

      // Test 3: ₹25,000 luxury package
      final calc3 = PaymentCalculation.fromTotal(25000.0);
      expect(calc3.totalAmount, 25000.0);
      expect(calc3.platformFee, 1250.0);
      expect(calc3.photographerAmount, 23750.0);
    });

    test('Client-side Razorpay Secret Isolation (Enforces Cloud Function routing)', () async {
      final paymentService = RazorpayPaymentServiceImpl();

      // Ensure client throws and does NOT hold hardcoded secrets or bypass backend verification
      expect(
        () => paymentService.createRazorpayOrder(
          bookingId: 'booking_123',
          amount: 8000.0,
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            'UNCONFIGURED_BACKEND_PAYMENT',
          ),
        ),
      );

      expect(
        () => paymentService.verifyPaymentSignature(
          orderId: 'order_123',
          paymentId: 'pay_123',
          signature: 'fake_signature',
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            'UNCONFIGURED_BACKEND_PAYMENT',
          ),
        ),
      );
    });
  });
}

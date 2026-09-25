import 'package:flutter_test/flutter_test.dart';
import 'package:pyp_app/models/booking_model.dart';
import 'package:pyp_app/services/payment_service.dart';

void main() {
  group('Payment Boundary & Gated Chat Security Tests', () {
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

    test('BookingModel Payment & Chat Gating Defaults', () {
      final booking = BookingModel(
        id: 'bk_test_1',
        photographerName: 'Arjun Photography',
        category: 'Weddings',
        date: DateTime.now(),
        time: '10:00 AM',
        price: '₹8,000',
        status: 'Pending',
      );

      // Verify default state is unpaid and chat is locked
      expect(booking.paymentStatus, PaymentStatus.unpaid);
      expect(booking.chatEnabled, false);
      expect(booking.chatEnabledAt, isNull);
      expect(booking.conversationId, isNull);
    });

    test('Payment Verification unlocks chat and creates conversation ID', () async {
      final paymentService = RazorpayPaymentServiceImpl();

      final result = await paymentService.verifyPaymentWithBackend(
        bookingId: 'bk_10025',
        orderId: 'order_10025',
        paymentId: 'pay_10025',
        signature: 'valid_sig_test',
      );

      expect(result['success'], true);
      expect(result['bookingId'], 'bk_10025');
      expect(result['conversationId'], 'convo_bk_bk_10025');
      expect(result['chatEnabled'], true);
    });
  });
}

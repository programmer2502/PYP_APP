import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onCancel;
  final VoidCallback? onMessage;
  final VoidCallback? onPay;

  const BookingCard({
    super.key,
    required this.booking,
    this.onCancel,
    this.onMessage,
    this.onPay,
  });

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'confirmed':
        return const Color(0xFF4ADE80);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFF87171);
      case 'pending':
      default:
        return const Color(0xFFFBBF24);
    }
  }

  Color statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'confirmed':
        return const Color(0xFF14532D).withValues(alpha: 0.35);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFF7F1D1D).withValues(alpha: 0.35);
      case 'pending':
      default:
        return const Color(0xFF78350F).withValues(alpha: 0.35);
    }
  }

  IconData statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'rejected':
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'pending':
      default:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = statusColor(booking.status);
    final bgColor = statusBgColor(booking.status);
    final icon = statusIcon(booking.status);
    final isPaid = booking.paymentStatus == PaymentStatus.paid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: booking.status.toLowerCase() == 'accepted'
              ? const Color(0xFF4ADE80).withValues(alpha: 0.25)
              : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.photographerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 12, color: color),
                    const SizedBox(width: 5),
                    Text(
                      booking.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking.category,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textFaint,
            ),
          ),
          const SizedBox(height: 13),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${booking.date.day}/${booking.date.month}/${booking.date.year}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    booking.endTime != null && booking.endTime!.isNotEmpty
                        ? '${booking.time} - ${booking.endTime}'
                        : booking.time,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              if (booking.duration.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.cardElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.duration,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.price,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPaid
                      ? const Color(0xFF14532D)
                      : (booking.status.toLowerCase() == 'pending'
                          ? Colors.white10
                          : Colors.amber.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPaid
                        ? Colors.greenAccent.withValues(alpha: 0.3)
                        : (booking.status.toLowerCase() == 'pending'
                            ? Colors.white12
                            : Colors.amberAccent.withValues(alpha: 0.3)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPaid
                          ? Icons.check_circle_rounded
                          : (booking.status.toLowerCase() == 'pending'
                              ? Icons.hourglass_empty_rounded
                              : Icons.payment_rounded),
                      size: 11,
                      color: isPaid
                          ? Colors.greenAccent
                          : (booking.status.toLowerCase() == 'pending'
                              ? Colors.white60
                              : Colors.amberAccent),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPaid
                          ? 'PAID (Razorpay)'
                          : (booking.status.toLowerCase() == 'pending'
                              ? 'PAYMENT LOCKED'
                              : 'READY TO PAY'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isPaid
                            ? Colors.greenAccent
                            : (booking.status.toLowerCase() == 'pending'
                                ? Colors.white60
                                : Colors.amberAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Status & Payment Guidance Notice
          if (booking.status.toLowerCase() == 'pending') ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF18181B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_clock_rounded, size: 14, color: Color(0xFFFBBF24)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Waiting for photographer to accept. Payment unlocks upon acceptance.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if ((booking.status.toLowerCase() == 'accepted' ||
                  booking.status.toLowerCase() == 'confirmed') &&
              !isPaid &&
              onPay != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF34D399)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Photographer accepted! Please complete payment to secure your slot.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF34D399),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                icon: const Icon(Icons.flash_on_rounded, size: 16, color: Colors.black),
                label: Text(
                  'Pay with Razorpay • ${booking.price}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
          if (onMessage != null || onCancel != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onMessage != null)
                  TextButton.icon(
                    onPressed: onMessage,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.cardElevated,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14),
                    label: const Text('Message', style: TextStyle(fontSize: 12)),
                  ),
                if (onMessage != null && onCancel != null) const SizedBox(width: 10),
                if (onCancel != null)
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: AppColors.textTertiary,
                    ),
                    child: const Text('Cancel booking'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/booking_model.dart';
import '../../models/photographer_model.dart';
import '../../providers/pyp_store.dart';

class DurationOption {
  final String label;
  final String subtitle;
  final double multiplier;
  final int minutes;

  const DurationOption({
    required this.label,
    required this.subtitle,
    required this.multiplier,
    required this.minutes,
  });
}

class BookingScreen extends StatefulWidget {
  final PhotographerModel photographer;
  final PypStore store;

  const BookingScreen({
    super.key,
    required this.photographer,
    required this.store,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  String selectedTime = '11:00 AM';
  final TextEditingController notesController = TextEditingController();
  StreamSubscription<List<BookingModel>>? _bookingsSubscription;
  List<BookingModel> _photographerBookings = [];
  final List<String> times = const [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '2:00 PM',
    '4:00 PM',
    '6:00 PM',
  ];

  static const List<DurationOption> durationOptions = [
    DurationOption(
      label: '30 min',
      subtitle: 'Quick shoot',
      multiplier: 1.0,
      minutes: 30,
    ),
    DurationOption(
      label: '1 hr',
      subtitle: 'Standard shoot',
      multiplier: 2.0,
      minutes: 60,
    ),
    DurationOption(
      label: '2 hrs',
      subtitle: 'Extended session',
      multiplier: 4.0,
      minutes: 120,
    ),
    DurationOption(
      label: '3 hrs',
      subtitle: 'Mini event',
      multiplier: 6.0,
      minutes: 180,
    ),
    DurationOption(
      label: '4 hrs',
      subtitle: 'Half-day shoot',
      multiplier: 8.0,
      minutes: 240,
    ),
    DurationOption(
      label: '8 hrs',
      subtitle: 'Full-day event',
      multiplier: 16.0,
      minutes: 480,
    ),
  ];

  late DurationOption selectedDuration;

  @override
  void initState() {
    super.initState();
    selectedDuration = durationOptions[1]; // Default to 1 hr
    selectedDate = DateTime.now().add(const Duration(days: 1));
    _listenToPhotographerBookings();
  }

  void _listenToPhotographerBookings() {
    final photoId = widget.photographer.id.isNotEmpty
        ? widget.photographer.id
        : widget.photographer.name;

    _bookingsSubscription = widget.store.bookingRepository
        .getPhotographerRequests(photoId)
        .listen(
      (items) {
        if (mounted) {
          setState(() {
            _photographerBookings = items;
            _adjustSelectedTimeIfBlocked();
          });
        }
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    notesController.dispose();
    super.dispose();
  }

  int? parseTimeToMinutes(String timeStr) {
    try {
      final parts = timeStr.trim().split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final period = parts.length > 1 ? parts[1].toUpperCase() : 'AM';
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return hour * 60 + minute;
    } catch (_) {
      return null;
    }
  }

  bool isSlotBlocked(String time) {
    if (selectedDate == null) return false;

    final photoAliases = {
      widget.photographer.id.toLowerCase().trim(),
      widget.photographer.uid.toLowerCase().trim(),
      widget.photographer.name.toLowerCase().trim(),
    }..removeWhere((s) => s.isEmpty);

    // Merge both live repository stream bookings and local store bookings
    final allBookings = <BookingModel>{
      ..._photographerBookings,
      ...widget.store.bookings,
    };

    final slotStart = parseTimeToMinutes(time);
    if (slotStart == null) return false;
    final slotEnd = slotStart + selectedDuration.minutes;

    for (final booking in allBookings) {
      final bPhotoId = booking.photographerId.toLowerCase().trim();
      final bPhotoName = booking.photographerName.toLowerCase().trim();
      final matchesPhoto =
          photoAliases.contains(bPhotoId) || photoAliases.contains(bPhotoName);

      if (!matchesPhoto) continue;

      // Ignore cancelled or rejected bookings
      if (booking.status.toLowerCase() == 'cancelled' ||
          booking.status.toLowerCase() == 'rejected') {
        continue;
      }

      // Check same date (day, month, year)
      if (booking.date.year != selectedDate!.year ||
          booking.date.month != selectedDate!.month ||
          booking.date.day != selectedDate!.day) {
        continue;
      }

      final bStart = parseTimeToMinutes(booking.time);
      if (bStart == null) {
        if (booking.time.trim().toLowerCase() == time.trim().toLowerCase()) {
          return true;
        }
        continue;
      }

      int bDuration = 60;
      if (booking.duration.isNotEmpty) {
        final match = RegExp(r'(\d+)').firstMatch(booking.duration);
        if (match != null) {
          final val = int.tryParse(match.group(1)!);
          if (val != null) {
            bDuration = booking.duration.contains('min') ? val : val * 60;
          }
        }
      }

      final bEnd = booking.endTime != null && booking.endTime!.isNotEmpty
          ? (parseTimeToMinutes(booking.endTime!) ?? (bStart + bDuration))
          : (bStart + bDuration);

      if (slotStart < bEnd && slotEnd > bStart) {
        return true;
      }
    }

    return false;
  }

  void _adjustSelectedTimeIfBlocked() {
    if (isSlotBlocked(selectedTime)) {
      for (final t in times) {
        if (!isSlotBlocked(t)) {
          selectedTime = t;
          return;
        }
      }
    }
  }

  double get baseRate {
    if (widget.photographer.startingPrice != null &&
        widget.photographer.startingPrice! > 0) {
      return widget.photographer.startingPrice!;
    }
    final cleaned = widget.photographer.price.replaceAll(',', '').replaceAll('₹', '');
    final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(cleaned);
    if (match != null) {
      final parsed = double.tryParse(match.group(1)!);
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }
    return 300.0;
  }

  double get totalAmount => baseRate * selectedDuration.multiplier;
  double get platformFee => totalAmount * 0.05;
  double get photographerAmount => totalAmount - platformFee;

  String calculateEndTime(String startTimeStr, int durationMinutes) {
    try {
      final parts = startTimeStr.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final period = parts.length > 1 ? parts[1].toUpperCase() : 'AM';
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      final startDateTime = DateTime(2026, 1, 1, hour, minute);
      final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));

      final endHour24 = endDateTime.hour;
      final endMin = endDateTime.minute.toString().padLeft(2, '0');
      final endPeriod = endHour24 >= 12 ? 'PM' : 'AM';
      final endHour12 =
          endHour24 == 0 ? 12 : (endHour24 > 12 ? endHour24 - 12 : endHour24);

      return '$endHour12:$endMin $endPeriod';
    } catch (_) {
      return '';
    }
  }

  Future<void> chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: AppColors.card,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
        _adjustSelectedTimeIfBlocked();
      });
    }
  }

  Future<void> confirmBooking() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date first.'),
        ),
      );
      return;
    }

    if (isSlotBlocked(selectedTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$selectedTime is already booked. Please select an available slot.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final calculatedEndTime = calculateEndTime(selectedTime, selectedDuration.minutes);

    final custIds = widget.store.currentUserChatIdentifiers;
    final photoIds = <String>{
      widget.photographer.id,
      widget.photographer.uid,
      widget.photographer.name,
      widget.photographer.email,
    }..removeWhere((s) => s.isEmpty);

    final booking = BookingModel(
      customerId: widget.store.user.uid.isNotEmpty
          ? widget.store.user.uid
          : (widget.store.user.email.isNotEmpty
              ? widget.store.user.email
              : 'guest_user'),
      customerName: widget.store.user.name.isNotEmpty && widget.store.user.name != 'PYP User'
          ? widget.store.user.name
          : (widget.store.user.email.isNotEmpty ? widget.store.user.email : 'Client'),
      customerEmail: widget.store.user.email,
      customerPhone: widget.store.user.phone,
      customerIdentifiers: custIds,
      photographerId: widget.photographer.id.isNotEmpty
          ? widget.photographer.id
          : widget.photographer.name,
      photographerUid: widget.photographer.uid,
      photographerName: widget.photographer.name,
      photographerEmail: widget.photographer.email,
      photographerIdentifiers: photoIds.toList(),
      category: widget.photographer.category,
      date: selectedDate!,
      time: selectedTime,
      endTime: calculatedEndTime,
      duration: selectedDuration.label,
      amount: totalAmount,
      platformFee: platformFee,
      photographerAmount: photographerAmount,
      status: 'Pending',
      paymentStatus: PaymentStatus.pending,
      price: '₹${totalAmount.toInt()}',
      notes: notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    await widget.store.addBooking(booking);

    // Refresh blocked state immediately
    setState(() {
      _adjustSelectedTimeIfBlocked();
    });

    if (!mounted) return;

    _showBookingReceiptDialog(
      calculatedEndTime: calculatedEndTime,
    );
  }

  void _showBookingReceiptDialog({
    required String calculatedEndTime,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Colors.amberAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Booking Request Sent',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your booking request has been sent to ${widget.photographer.name}. Once they review and accept your request, the payment option will be enabled in your Bookings tab.',
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Date & Time:', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                        Text(
                          '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} • $selectedTime',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Duration:', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                        Text(
                          '${selectedDuration.label} ($calculatedEndTime)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                        Text(
                          '₹${totalAmount.toInt()}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Payment Status:', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PAY ON CONFIRMATION',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.amberAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final endTimeStr = calculateEndTime(selectedTime, selectedDuration.minutes);
    final allBlocked = selectedDate != null && times.every((t) => isSlotBlocked(t));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Book Photographer',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photographer Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.borderSubtle,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.mediaPlaceholder,
                      borderRadius: BorderRadius.circular(16),
                      image: widget.photographer.displayImages.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(widget.photographer.displayImages.first),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.photographer.displayImages.isEmpty
                        ? const Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.textMuted,
                          )
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.photographer.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.cardElevated,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.photographer.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '₹${baseRate.toInt()} / 30 min base',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Select Date
            const Text(
              'Select date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: chooseDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      selectedDate == null
                          ? 'Choose a date'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: selectedDate == null
                            ? AppColors.textFaint
                            : Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Select Start Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select start time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (selectedDate != null)
                  Text(
                    '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Blocked or booked slots are marked and unavailable',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: times.map((time) {
                final blocked = isSlotBlocked(time);
                final selected = selectedTime == time && !blocked;

                return GestureDetector(
                  onTap: () {
                    if (blocked) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.block_flipped, color: Colors.redAccent, size: 18),
                              const SizedBox(width: 8),
                              Text('$time is already booked on this date.'),
                            ],
                          ),
                          backgroundColor: AppColors.card,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      selectedTime = time;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: blocked
                          ? const Color(0xFF1B1416)
                          : (selected ? Colors.white : AppColors.card),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: blocked
                            ? Colors.redAccent.withValues(alpha: 0.35)
                            : (selected ? Colors.white : AppColors.borderLight),
                        width: selected ? 1.5 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            decoration: blocked ? TextDecoration.lineThrough : null,
                            decorationColor: Colors.redAccent,
                            color: blocked
                                ? Colors.white38
                                : (selected ? Colors.black : AppColors.textSecondary),
                          ),
                        ),
                        if (blocked) ...[
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'Booked',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (allBlocked)
              Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.event_busy_rounded, color: Colors.redAccent, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This photographer is fully booked on this date. Please pick another date.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 28),

            // Select Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select duration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (endTimeStr.isNotEmpty)
                  Text(
                    '$selectedTime - $endTimeStr',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Pricing scales dynamically based on duration (₹300/30m base)',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.45,
              ),
              itemCount: durationOptions.length,
              itemBuilder: (context, index) {
                final option = durationOptions[index];
                final isSelected = selectedDuration == option;
                final optionPrice = (baseRate * option.multiplier).toInt();

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDuration = option;
                      _adjustSelectedTimeIfBlocked();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.white : AppColors.borderLight,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          option.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '₹$optionPrice',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.black87 : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 26),

            // Price Breakdown Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Payment Summary',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.cardElevated,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${selectedDuration.label} shoot',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Base Rate (${selectedDuration.multiplier.toStringAsFixed(selectedDuration.multiplier % 1 == 0 ? 0 : 1)}x of ₹${baseRate.toInt()}/30m)',
                        style: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                      ),
                      Text(
                        '₹${totalAmount.toInt()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Platform fee (5% included)',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                      ),
                      Text(
                        '₹${platformFee.toInt()}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Photographer receives',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                      ),
                      Text(
                        '₹${photographerAmount.toInt()}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppColors.borderSubtle, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '₹${totalAmount.toInt()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Message for photographer
            const Text(
              'Message for photographer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Tell them about your event, location details, etc...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 35),
            if (!widget.photographer.acceptingBookings)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This photographer has paused their booking schedule.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Guidance Notice: Payment enables upon acceptance
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF38BDF8),
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No payment is required right now. Send your request to the creative artist. Once accepted, payment will be enabled in your Bookings tab.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Primary: Send Booking Request Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (widget.photographer.acceptingBookings && !allBlocked)
                    ? confirmBooking
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: AppColors.cardElevated,
                  disabledForegroundColor: AppColors.textMuted,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, size: 18, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      !widget.photographer.acceptingBookings
                          ? 'Currently Unavailable'
                          : (allBlocked
                              ? 'Fully Booked on Selected Date'
                              : 'Send Booking Request • ₹${totalAmount.toInt()}'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Security Badge
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Instant chat notification • Razorpay secure checkout upon acceptance',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  accepted,
  rejected,
  cancelled,
  completed;

  static BookingStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return BookingStatus.accepted;
      case 'rejected':
        return BookingStatus.rejected;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      case 'pending':
      default:
        return BookingStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  bool canTransitionTo(BookingStatus next) {
    switch (this) {
      case BookingStatus.pending:
        return next == BookingStatus.accepted ||
            next == BookingStatus.rejected ||
            next == BookingStatus.cancelled;
      case BookingStatus.accepted:
        return next == BookingStatus.cancelled ||
            next == BookingStatus.completed;
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
      case BookingStatus.completed:
        return false;
    }
  }
}

enum PaymentStatus {
  unpaid,
  pending,
  paid,
  failed,
  refunded,
  partiallyRefunded;

  static PaymentStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return PaymentStatus.paid;
      case 'pending':
        return PaymentStatus.pending;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'partially_refunded':
      case 'partiallyrefunded':
        return PaymentStatus.partiallyRefunded;
      case 'unpaid':
      default:
        return PaymentStatus.unpaid;
    }
  }

  String get value => name;
}

class BookingModel {
  final String id;
  final String customerId;
  final String photographerId;
  final String photographerName;
  final String category;
  final DateTime date;
  final String time;
  final String? endTime;
  final String location;
  final String notes;
  final double amount;
  final double platformFee;
  final double photographerAmount;
  String status;
  final PaymentStatus paymentStatus;
  final String price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingModel({
    this.id = '',
    this.customerId = '',
    this.photographerId = '',
    required this.photographerName,
    required this.category,
    required this.date,
    required this.time,
    this.endTime,
    this.location = '',
    this.notes = '',
    this.amount = 0.0,
    this.platformFee = 0.0,
    this.photographerAmount = 0.0,
    required this.status,
    this.paymentStatus = PaymentStatus.unpaid,
    required this.price,
    this.createdAt,
    this.updatedAt,
  });

  BookingStatus get bookingStatus => BookingStatus.fromString(status);

  factory BookingModel.fromMap(Map<String, dynamic> map, String docId) {
    return BookingModel(
      id: docId,
      customerId: map['customerId'] as String? ?? '',
      photographerId: map['photographerId'] as String? ?? '',
      photographerName: map['photographerName'] as String? ?? '',
      category: map['category'] as String? ?? map['eventType'] as String? ?? 'General',
      date: map['eventDate'] is Timestamp
          ? (map['eventDate'] as Timestamp).toDate()
          : (map['date'] is Timestamp
              ? (map['date'] as Timestamp).toDate()
              : DateTime.now()),
      time: map['startTime'] as String? ?? map['time'] as String? ?? '10:00 AM',
      endTime: map['endTime'] as String?,
      location: map['location'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      platformFee: (map['platformFee'] as num?)?.toDouble() ?? 0.0,
      photographerAmount: (map['photographerAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'Pending',
      paymentStatus: PaymentStatus.fromString(map['paymentStatus'] as String?),
      price: map['price'] as String? ?? (map['amount'] != null ? '₹${map['amount']}' : '₹0'),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': id,
      'customerId': customerId,
      'photographerId': photographerId,
      'photographerName': photographerName,
      'category': category,
      'eventType': category,
      'eventDate': Timestamp.fromDate(date),
      'date': Timestamp.fromDate(date),
      'startTime': time,
      'time': time,
      'endTime': endTime,
      'location': location,
      'notes': notes,
      'amount': amount,
      'platformFee': platformFee,
      'photographerAmount': photographerAmount,
      'status': status,
      'paymentStatus': paymentStatus.value,
      'price': price,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? customerId,
    String? photographerId,
    String? photographerName,
    String? category,
    DateTime? date,
    String? time,
    String? endTime,
    String? location,
    String? notes,
    double? amount,
    double? platformFee,
    double? photographerAmount,
    String? status,
    PaymentStatus? paymentStatus,
    String? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      photographerId: photographerId ?? this.photographerId,
      photographerName: photographerName ?? this.photographerName,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      amount: amount ?? this.amount,
      platformFee: platformFee ?? this.platformFee,
      photographerAmount: photographerAmount ?? this.photographerAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

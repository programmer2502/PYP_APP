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
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final List<String> customerIdentifiers;
  final String photographerId;
  final String photographerUid;
  final String photographerName;
  final String photographerEmail;
  final List<String> photographerIdentifiers;
  final String category;
  final DateTime date;
  final String time;
  final String duration;
  final String? endTime;
  final String location;
  final String notes;
  final double amount;
  final double platformFee;
  final double photographerAmount;
  String status;
  final PaymentStatus paymentStatus;
  final bool chatEnabled;
  final DateTime? chatEnabledAt;
  final String? conversationId;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? razorpaySignature;
  final String price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingModel({
    this.id = '',
    this.customerId = '',
    this.customerName = '',
    this.customerEmail = '',
    this.customerPhone = '',
    this.customerIdentifiers = const [],
    this.photographerId = '',
    this.photographerUid = '',
    required this.photographerName,
    this.photographerEmail = '',
    this.photographerIdentifiers = const [],
    required this.category,
    required this.date,
    required this.time,
    this.duration = '1 hour',
    this.endTime,
    this.location = '',
    this.notes = '',
    this.amount = 0.0,
    this.platformFee = 0.0,
    this.photographerAmount = 0.0,
    required this.status,
    this.paymentStatus = PaymentStatus.unpaid,
    this.chatEnabled = false,
    this.chatEnabledAt,
    this.conversationId,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.razorpaySignature,
    required this.price,
    this.createdAt,
    this.updatedAt,
  });

  BookingStatus get bookingStatus => BookingStatus.fromString(status);

  bool matchesCustomer(List<String> identifiers) {
    final clean = identifiers
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toSet();
    if (clean.isEmpty) return false;

    final customerSet = <String>{
      customerId.trim().toLowerCase(),
      customerEmail.trim().toLowerCase(),
      customerName.trim().toLowerCase(),
      customerPhone.trim().toLowerCase(),
      ...customerIdentifiers.map((s) => s.trim().toLowerCase()),
    }..removeWhere((s) => s.isEmpty);

    return customerSet.any((c) => clean.contains(c));
  }

  bool matchesPhotographer(List<String> identifiers) {
    final clean = identifiers
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toSet();
    if (clean.isEmpty) return false;

    final photoSet = <String>{
      photographerId.trim().toLowerCase(),
      photographerUid.trim().toLowerCase(),
      photographerName.trim().toLowerCase(),
      photographerEmail.trim().toLowerCase(),
      ...photographerIdentifiers.map((s) => s.trim().toLowerCase()),
    }..removeWhere((s) => s.isEmpty);

    return photoSet.any((p) => clean.contains(p));
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawCustomerIds = map['customerIdentifiers'];
    final customerIds = rawCustomerIds is List
        ? rawCustomerIds.map((e) => e.toString()).toList()
        : <String>[];

    final rawPhotoIds = map['photographerIdentifiers'];
    final photoIds = rawPhotoIds is List
        ? rawPhotoIds.map((e) => e.toString()).toList()
        : <String>[];

    DateTime? parsedChatEnabledAt;
    if (map['chatEnabledAt'] is Timestamp) {
      parsedChatEnabledAt = (map['chatEnabledAt'] as Timestamp).toDate();
    } else if (map['chatEnabledAt'] is String) {
      parsedChatEnabledAt = DateTime.tryParse(map['chatEnabledAt'] as String);
    }

    return BookingModel(
      id: docId,
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      customerEmail: map['customerEmail'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      customerIdentifiers: customerIds,
      photographerId: map['photographerId'] as String? ?? '',
      photographerUid: map['photographerUid'] as String? ?? '',
      photographerName: map['photographerName'] as String? ?? '',
      photographerEmail: map['photographerEmail'] as String? ?? '',
      photographerIdentifiers: photoIds,
      category: map['category'] as String? ?? map['eventType'] as String? ?? 'General',
      date: map['eventDate'] is Timestamp
          ? (map['eventDate'] as Timestamp).toDate()
          : (map['date'] is Timestamp
              ? (map['date'] as Timestamp).toDate()
              : DateTime.now()),
      time: map['startTime'] as String? ?? map['time'] as String? ?? '10:00 AM',
      duration: map['duration'] as String? ?? '1 hour',
      endTime: map['endTime'] as String?,
      location: map['location'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      platformFee: (map['platformFee'] as num?)?.toDouble() ?? 0.0,
      photographerAmount: (map['photographerAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'Pending',
      paymentStatus: PaymentStatus.fromString(map['paymentStatus'] as String?),
      chatEnabled: map['chatEnabled'] as bool? ?? false,
      chatEnabledAt: parsedChatEnabledAt,
      conversationId: map['conversationId'] as String?,
      razorpayPaymentId: map['razorpayPaymentId'] as String?,
      razorpayOrderId: map['razorpayOrderId'] as String?,
      razorpaySignature: map['razorpaySignature'] as String?,
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
    final cIds = <String>{
      customerId.trim(),
      customerEmail.trim(),
      customerName.trim(),
      customerPhone.trim(),
      ...customerIdentifiers.map((s) => s.trim()),
    }..removeWhere((s) => s.isEmpty);

    final pIds = <String>{
      photographerId.trim(),
      photographerUid.trim(),
      photographerName.trim(),
      photographerEmail.trim(),
      ...photographerIdentifiers.map((s) => s.trim()),
    }..removeWhere((s) => s.isEmpty);

    return {
      'bookingId': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerIdentifiers': cIds.toList(),
      'photographerId': photographerId,
      'photographerUid': photographerUid,
      'photographerName': photographerName,
      'photographerEmail': photographerEmail,
      'photographerIdentifiers': pIds.toList(),
      'category': category,
      'eventType': category,
      'eventDate': Timestamp.fromDate(date),
      'date': Timestamp.fromDate(date),
      'startTime': time,
      'time': time,
      'duration': duration,
      'endTime': endTime,
      'location': location,
      'notes': notes,
      'amount': amount,
      'platformFee': platformFee,
      'photographerAmount': photographerAmount,
      'status': status,
      'paymentStatus': paymentStatus.value,
      'chatEnabled': chatEnabled,
      if (chatEnabledAt != null) 'chatEnabledAt': Timestamp.fromDate(chatEnabledAt!),
      if (conversationId != null) 'conversationId': conversationId,
      if (razorpayPaymentId != null) 'razorpayPaymentId': razorpayPaymentId,
      if (razorpayOrderId != null) 'razorpayOrderId': razorpayOrderId,
      if (razorpaySignature != null) 'razorpaySignature': razorpaySignature,
      'price': price,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    List<String>? customerIdentifiers,
    String? photographerId,
    String? photographerUid,
    String? photographerName,
    String? photographerEmail,
    List<String>? photographerIdentifiers,
    String? category,
    DateTime? date,
    String? time,
    String? duration,
    String? endTime,
    String? location,
    String? notes,
    double? amount,
    double? platformFee,
    double? photographerAmount,
    String? status,
    PaymentStatus? paymentStatus,
    bool? chatEnabled,
    DateTime? chatEnabledAt,
    String? conversationId,
    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? razorpaySignature,
    String? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerIdentifiers: customerIdentifiers ?? this.customerIdentifiers,
      photographerId: photographerId ?? this.photographerId,
      photographerUid: photographerUid ?? this.photographerUid,
      photographerName: photographerName ?? this.photographerName,
      photographerEmail: photographerEmail ?? this.photographerEmail,
      photographerIdentifiers: photographerIdentifiers ?? this.photographerIdentifiers,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      amount: amount ?? this.amount,
      platformFee: platformFee ?? this.platformFee,
      photographerAmount: photographerAmount ?? this.photographerAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      chatEnabled: chatEnabled ?? this.chatEnabled,
      chatEnabledAt: chatEnabledAt ?? this.chatEnabledAt,
      conversationId: conversationId ?? this.conversationId,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpaySignature: razorpaySignature ?? this.razorpaySignature,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

enum AvailabilityStatus {
  available,
  blocked,
  booked;

  static AvailabilityStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'blocked':
        return AvailabilityStatus.blocked;
      case 'booked':
        return AvailabilityStatus.booked;
      case 'available':
      default:
        return AvailabilityStatus.available;
    }
  }

  String get value => name;
}

class AvailabilityModel {
  final String id;
  final String photographerId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final AvailabilityStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AvailabilityModel({
    required this.id,
    required this.photographerId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = AvailabilityStatus.available,
    this.createdAt,
    this.updatedAt,
  });

  factory AvailabilityModel.fromMap(Map<String, dynamic> map, String docId) {
    return AvailabilityModel(
      id: docId,
      photographerId: map['photographerId'] as String? ?? '',
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      startTime: map['startTime'] as String? ?? '09:00 AM',
      endTime: map['endTime'] as String? ?? '06:00 PM',
      status: AvailabilityStatus.fromString(map['status'] as String?),
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
      'availabilityId': id,
      'photographerId': photographerId,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'status': status.value,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AvailabilityModel copyWith({
    String? id,
    String? photographerId,
    DateTime? date,
    String? startTime,
    String? endTime,
    AvailabilityStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AvailabilityModel(
      id: id ?? this.id,
      photographerId: photographerId ?? this.photographerId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

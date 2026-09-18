import 'package:cloud_firestore/cloud_firestore.dart';

class PhotographerModel {
  final String id;
  final String uid;
  String name;
  String category;
  String specialty;
  String rating;
  String price;
  double? startingPrice;
  String location;
  String bio;
  String phone;
  String email;
  String instagram;
  bool verified;
  bool acceptingBookings;
  List<String> portfolio;
  String? profileImageUrl;
  int reviewCount;
  int experienceYears;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PhotographerModel({
    this.id = '',
    this.uid = '',
    required this.name,
    required this.category,
    required this.specialty,
    required this.rating,
    required this.price,
    this.startingPrice,
    required this.location,
    required this.bio,
    required this.phone,
    required this.email,
    required this.instagram,
    required this.verified,
    required this.acceptingBookings,
    required this.portfolio,
    this.profileImageUrl,
    this.reviewCount = 0,
    this.experienceYears = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory PhotographerModel.fromMap(Map<String, dynamic> map, String docId) {
    return PhotographerModel(
      id: docId,
      uid: map['uid'] as String? ?? docId,
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'Weddings',
      specialty: map['specialty'] as String? ?? '',
      rating: map['rating']?.toString() ?? '5.0',
      price: map['price'] as String? ?? (map['startingPrice'] != null ? '₹${map['startingPrice']} onwards' : '₹5,000 onwards'),
      startingPrice: (map['startingPrice'] as num?)?.toDouble(),
      location: map['location'] as String? ?? 'Bengaluru',
      bio: map['bio'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      instagram: map['instagram'] as String? ?? '',
      verified: map['isVerified'] as bool? ?? map['verified'] as bool? ?? false,
      acceptingBookings: map['isAvailable'] as bool? ?? map['acceptingBookings'] as bool? ?? true,
      portfolio: List<String>.from(map['portfolio'] as List<dynamic>? ?? []),
      profileImageUrl: map['profileImageUrl'] as String?,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      experienceYears: (map['experienceYears'] as num?)?.toInt() ?? 0,
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
      'photographerId': id,
      'uid': uid,
      'name': name,
      'category': category,
      'specialty': specialty,
      'rating': rating,
      'price': price,
      'startingPrice': startingPrice,
      'location': location,
      'bio': bio,
      'phone': phone,
      'email': email,
      'instagram': instagram,
      'isVerified': verified,
      'isAvailable': acceptingBookings,
      'portfolio': portfolio,
      'profileImageUrl': profileImageUrl,
      'reviewCount': reviewCount,
      'experienceYears': experienceYears,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  PhotographerModel copyWith({
    String? id,
    String? uid,
    String? name,
    String? category,
    String? specialty,
    String? rating,
    String? price,
    double? startingPrice,
    String? location,
    String? bio,
    String? phone,
    String? email,
    String? instagram,
    bool? verified,
    bool? acceptingBookings,
    List<String>? portfolio,
    String? profileImageUrl,
    int? reviewCount,
    int? experienceYears,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PhotographerModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      category: category ?? this.category,
      specialty: specialty ?? this.specialty,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      startingPrice: startingPrice ?? this.startingPrice,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      instagram: instagram ?? this.instagram,
      verified: verified ?? this.verified,
      acceptingBookings: acceptingBookings ?? this.acceptingBookings,
      portfolio: portfolio ?? List<String>.from(this.portfolio),
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      reviewCount: reviewCount ?? this.reviewCount,
      experienceYears: experienceYears ?? this.experienceYears,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

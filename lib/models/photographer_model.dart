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
  final String serviceType; // 'Photographer', 'Videographer', or 'Both'
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
    this.serviceType = 'Photographer',
    this.createdAt,
    this.updatedAt,
  });

  bool get isPhotographer =>
      serviceType.toLowerCase() == 'photographer' ||
      serviceType.toLowerCase() == 'both' ||
      serviceType.isEmpty;

  bool get isVideographer =>
      serviceType.toLowerCase() == 'videographer' ||
      serviceType.toLowerCase() == 'both' ||
      category.toLowerCase().contains('video') ||
      specialty.toLowerCase().contains('video') ||
      specialty.toLowerCase().contains('cinematograph') ||
      bio.toLowerCase().contains('video') ||
      bio.toLowerCase().contains('cinematograph') ||
      bio.toLowerCase().contains('film');

  static List<String> defaultCategoryImages(String category) {
    switch (category.toLowerCase()) {
      case 'weddings':
        return const [
          'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1606800052052-a08af7148866?w=800&auto=format&fit=crop&q=80',
        ];
      case 'portraits':
      case 'fashion':
        return const [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&auto=format&fit=crop&q=80',
        ];
      case 'events':
        return const [
          'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=800&auto=format&fit=crop&q=80',
        ];
      case 'business':
      default:
        return const [
          'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800&auto=format&fit=crop&q=80',
        ];
    }
  }

  List<String> get displayImages {
    final List<String> list = [];
    if (profileImageUrl != null &&
        (profileImageUrl!.startsWith('http://') || profileImageUrl!.startsWith('https://'))) {
      list.add(profileImageUrl!);
    }
    for (final item in portfolio) {
      if (item.startsWith('http://') || item.startsWith('https://')) {
        if (!list.contains(item)) list.add(item);
      }
    }

    if (list.length < 3) {
      final defaults = defaultCategoryImages(category);
      for (final img in defaults) {
        if (!list.contains(img)) list.add(img);
        if (list.length >= 4) break;
      }
    }
    return list;
  }

  factory PhotographerModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawService = map['serviceType'] as String?;
    final category = map['category'] as String? ?? 'Weddings';
    final specialty = map['specialty'] as String? ?? '';
    final bio = map['bio'] as String? ?? '';

    String inferredService = 'Photographer';
    if (rawService != null && rawService.isNotEmpty) {
      inferredService = rawService;
    } else {
      final combined = '$category $specialty $bio'.toLowerCase();
      if (combined.contains('videograph') ||
          combined.contains('cinematograph') ||
          combined.contains('film')) {
        inferredService = combined.contains('photo') ? 'Both' : 'Videographer';
      }
    }

    return PhotographerModel(
      id: docId,
      uid: map['uid'] as String? ?? docId,
      name: map['name'] as String? ?? '',
      category: category,
      specialty: specialty,
      rating: map['rating']?.toString() ?? '5.0',
      price: map['price'] as String? ??
          (map['startingPrice'] != null
              ? '₹${map['startingPrice']} onwards'
              : '₹5,000 onwards'),
      startingPrice: (map['startingPrice'] as num?)?.toDouble(),
      location: map['location'] as String? ?? 'Bengaluru',
      bio: bio,
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      instagram: map['instagram'] as String? ?? '',
      verified: map['isVerified'] as bool? ?? map['verified'] as bool? ?? false,
      acceptingBookings:
          map['isAvailable'] as bool? ?? map['acceptingBookings'] as bool? ?? true,
      portfolio: List<String>.from(map['portfolio'] as List<dynamic>? ?? []),
      profileImageUrl: map['profileImageUrl'] as String?,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      experienceYears: (map['experienceYears'] as num?)?.toInt() ?? 0,
      serviceType: inferredService,
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
      'serviceType': serviceType,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
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
    String? serviceType,
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
      serviceType: serviceType ?? this.serviceType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

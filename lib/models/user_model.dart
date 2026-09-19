import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  customer,
  photographer;

  static UserRole fromString(String? role) {
    if (role == 'photographer') return UserRole.photographer;
    return UserRole.customer;
  }

  String get value => name;
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String city;
  final UserRole role;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.city = '',
    this.role = UserRole.customer,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] as String? ?? 'PYP User',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      city: map['city'] as String? ?? '',
      role: UserRole.fromString(map['role'] as String?),
      profileImageUrl: map['profileImageUrl'] as String?,
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
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'role': role.value,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? city,
    UserRole? role,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Backward compatible UserProfile class for in-memory store compatibility
class UserProfile {
  String uid;
  String name;
  String email;
  String phone;
  String city;
  String? profileImageUrl;

  UserProfile({
    this.uid = '',
    this.name = 'PYP User',
    this.email = 'user@example.com',
    this.phone = '',
    this.city = '',
    this.profileImageUrl,
  });

  UserModel toUserModel([String? explicitUid]) {
    final finalUid = (explicitUid != null && explicitUid.isNotEmpty) ? explicitUid : uid;
    return UserModel(
      uid: finalUid,
      name: name,
      email: email,
      phone: phone,
      city: city,
      profileImageUrl: profileImageUrl,
    );
  }
}


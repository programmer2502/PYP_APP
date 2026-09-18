import 'package:cloud_firestore/cloud_firestore.dart';

class PortfolioModel {
  final String id;
  final String photographerId;
  final String title;
  final String description;
  final String imageUrl;
  final String storagePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PortfolioModel({
    required this.id,
    required this.photographerId,
    required this.title,
    this.description = '',
    required this.imageUrl,
    this.storagePath = '',
    this.createdAt,
    this.updatedAt,
  });

  factory PortfolioModel.fromMap(Map<String, dynamic> map, String docId) {
    return PortfolioModel(
      id: docId,
      photographerId: map['photographerId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      storagePath: map['storagePath'] as String? ?? '',
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
      'portfolioId': id,
      'photographerId': photographerId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'storagePath': storagePath,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  PortfolioModel copyWith({
    String? id,
    String? photographerId,
    String? title,
    String? description,
    String? imageUrl,
    String? storagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PortfolioModel(
      id: id ?? this.id,
      photographerId: photographerId ?? this.photographerId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      storagePath: storagePath ?? this.storagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

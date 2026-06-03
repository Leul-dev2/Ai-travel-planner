// ─── User Model (Data Layer) ────────────────────────────────────────
// Firestore-compatible data model that maps to/from UserEntity.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? nationality;
  final String preferredCurrency;
  final String language;
  final String budgetPreference;
  final List<String> travelInterests;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.nationality,
    this.preferredCurrency = 'USD',
    this.language = 'en',
    this.budgetPreference = 'economy',
    this.travelInterests = const [],
    this.role = 'user',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Firestore document.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      nationality: data['nationality'] as String?,
      preferredCurrency: data['preferredCurrency'] as String? ?? 'USD',
      language: data['language'] as String? ?? 'en',
      budgetPreference: data['budgetPreference'] as String? ?? 'economy',
      travelInterests:
          List<String>.from(data['travelInterests'] as List? ?? []),
      role: data['role'] as String? ?? 'user',
      createdAt: _parseFirestoreDate(data['createdAt']),
      updatedAt: _parseFirestoreDate(data['updatedAt']),
    );
  }

  /// Supports Timestamp (native), ISO strings (legacy), and epoch millis.
  static DateTime _parseFirestoreDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  /// Create from JSON (legacy API compatibility).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      nationality: json['nationality'] as String?,
      preferredCurrency: json['preferredCurrency'] as String? ?? 'USD',
      language: json['language'] as String? ?? 'en',
      budgetPreference: json['budgetPreference'] as String? ?? 'economy',
      travelInterests:
          List<String>.from(json['travelInterests'] as List? ?? []),
      role: json['role'] as String? ?? 'user',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Serialize to Firestore document data.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'nationality': nationality,
      'preferredCurrency': preferredCurrency,
      'language': language,
      'budgetPreference': budgetPreference,
      'travelInterests': travelInterests,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert to domain entity.
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      photoUrl: photoUrl,
      nationality: nationality,
      preferredCurrency: preferredCurrency,
      language: language,
      budgetPreference: budgetPreference,
      travelInterests: travelInterests,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create model from domain entity.
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      photoUrl: entity.photoUrl,
      nationality: entity.nationality,
      preferredCurrency: entity.preferredCurrency,
      language: entity.language,
      budgetPreference: entity.budgetPreference,
      travelInterests: entity.travelInterests,
      role: entity.role,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

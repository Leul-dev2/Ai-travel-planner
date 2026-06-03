// ─── User Entity ────────────────────────────────────────────────────
// Domain entity for the authenticated user.
// This file will be enhanced with Freezed code generation once build_runner runs.

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? nationality;
  final String preferredCurrency;
  final String language;
  final String budgetPreference;
  final List<String> travelInterests;
  final String role; // 'user' | 'admin'
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
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

  bool get isAdmin => role == 'admin';

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? nationality,
    String? preferredCurrency,
    String? language,
    String? budgetPreference,
    List<String>? travelInterests,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      nationality: nationality ?? this.nationality,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      language: language ?? this.language,
      budgetPreference: budgetPreference ?? this.budgetPreference,
      travelInterests: travelInterests ?? this.travelInterests,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, email, name, role];
}

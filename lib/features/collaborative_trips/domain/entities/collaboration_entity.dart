// ─── Collaborative Trip Entity ──────────────────────────────────────
// Domain entities for shared trip collaboration.

import 'package:equatable/equatable.dart';

enum CollaboratorRole { owner, editor, viewer }

class CollaboratorEntity extends Equatable {
  final String userId;
  final String name;
  final String? email;
  final String? photoUrl;
  final CollaboratorRole role;
  final DateTime joinedAt;

  const CollaboratorEntity({
    required this.userId,
    required this.name,
    this.email,
    this.photoUrl,
    this.role = CollaboratorRole.editor,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [userId, role];
}

class TripComment extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String? activityRef;
  final DateTime createdAt;

  const TripComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    this.activityRef,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, text];
}

class ActivityVote extends Equatable {
  final String id;
  final String userId;
  final String activityId;
  final bool isUpvote;
  final DateTime createdAt;

  const ActivityVote({
    required this.id,
    required this.userId,
    required this.activityId,
    required this.isUpvote,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, activityId, isUpvote];
}

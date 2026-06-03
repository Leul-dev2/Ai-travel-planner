// ─── Chat Entity ────────────────────────────────────────────────────
// Domain entities for AI chat conversations.

import 'package:equatable/equatable.dart';

enum ChatRole { user, assistant, system }

class ChatMessage extends Equatable {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.metadata,
  });

  /// FIXED FOR OPTION B: Safely extracts the provider from the generic metadata map
  String? get provider => metadata?['provider'] as String?;

  @override
  List<Object?> get props => [id, role, content];
}

class ChatSession extends Equatable {
  final String id;
  final String userId;
  final String? tripId;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime lastMessageAt;

  const ChatSession({
    required this.id,
    required this.userId,
    this.tripId,
    this.messages = const [],
    required this.createdAt,
    required this.lastMessageAt,
  });

  @override
  List<Object?> get props => [id, userId, tripId];
}

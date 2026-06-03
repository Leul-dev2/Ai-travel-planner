import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ai_fallback_chain.dart';
import '../../data/ai_providers_registry.dart';
import '../../domain/entities/chat_entity.dart';

// Chat state holding the list of messages
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final AIFallbackChain _aiChain;
  bool isLoading = false;

  ChatNotifier(this._aiChain)
      : super([
          ChatMessage(
            id: 'welcome',
            role: ChatRole.assistant,
            content:
                'Hi there! I am your AI Travel Assistant. How can I help you plan your next adventure?',
            createdAt: DateTime.now(),
          )
        ]);

  void clearHistory() {
    state = [
      ChatMessage(
        id: 'welcome',
        role: ChatRole.assistant,
        content:
            'Hi there! I am your AI Travel Assistant. How can I help you plan your next adventure?',
        createdAt: DateTime.now(),
      )
    ];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.user,
      content: text,
      createdAt: DateTime.now(),
    );
    state = [...state, userMsg];
    isLoading = true;

    try {
      // Prepare history
      final history = state
          .map((m) => {
                'role': m.role == ChatRole.user ? 'user' : 'assistant',
                'content': m.content
              })
          .toList();

      // Call AI
      final aiResponse = await _aiChain.executeChat(history, text);

      // Add AI response
      final aiMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: ChatRole.assistant,
        content: aiResponse.content,
        createdAt: DateTime.now(),
      );
      state = [...state, aiMsg];
    } catch (e) {
      // Add error message
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: ChatRole.system,
        content: 'Sorry, I encountered an error: $e',
        createdAt: DateTime.now(),
      );
      state = [...state, errorMsg];
    } finally {
      isLoading = false;
    }
  }
}

// Provider for ChatNotifier
final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final aiChain = ref.watch(aiFallbackChainProvider);
  return ChatNotifier(aiChain);
});

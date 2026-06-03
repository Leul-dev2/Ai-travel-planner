// ─── OpenAI Provider ────────────────────────────────────────────────
// AI Provider implementation for OpenAI GPT models.

import 'package:dart_openai/dart_openai.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import 'ai_fallback_chain.dart';

class OpenAIProvider implements AIProvider {
  final String _modelId;
  bool _isInitialized = false;

  OpenAIProvider({String modelId = 'gpt-4o'}) : _modelId = modelId;

  void _init() {
    if (_isInitialized) return;
    final apiKey = AppConfig.openAiApiKey;
    if (apiKey.isEmpty || apiKey == 'your-openai-key') {
      throw AIException(
        message: 'OpenAI API key not configured',
        provider: 'OpenAI',
      );
    }
    OpenAI.apiKey = apiKey;
    _isInitialized = true;
  }

  @override
  String get name => 'OpenAI ($_modelId)';

  @override
  Future<AIResponse> generate(AIRequest request) async {
    _init();

    try {
      final systemPrompt = request.prompt;

      final chatCompletion = await OpenAI.instance.chat.create(
        model: _modelId,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  systemPrompt)
            ],
          ),
        ],
        temperature: request.temperature,
        maxTokens: request.maxTokens,
        responseFormat: const {'type': 'json_object'},
      );

      final content =
          chatCompletion.choices.first.message.content?.first.text ?? '';

      return AIResponse(
        content: content,
        provider: name,
        tokensUsed: chatCompletion.usage.totalTokens,
        metadata: {
          'model': _modelId,
          'finishReason': chatCompletion.choices.first.finishReason,
        },
      );
    } catch (e) {
      AppLogger.error('OpenAI generation failed', e);
      throw AIException(
        message: 'OpenAI generation failed: $e',
        provider: name,
      );
    }
  }

  @override
  Future<AIResponse> chat(
      List<Map<String, String>> history, String message) async {
    _init();

    try {
      final messages = history.map((m) {
        final role = m['role'] == 'user'
            ? OpenAIChatMessageRole.user
            : (m['role'] == 'system'
                ? OpenAIChatMessageRole.system
                : OpenAIChatMessageRole.assistant);
        return OpenAIChatCompletionChoiceMessageModel(
          role: role,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
                m['content'] ?? '')
          ],
        );
      }).toList();

      messages.add(OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(message)
        ],
      ));

      final chatCompletion = await OpenAI.instance.chat.create(
        model: _modelId,
        messages: messages,
        temperature: 0.7,
      );

      final content =
          chatCompletion.choices.first.message.content?.first.text ?? '';

      return AIResponse(
        content: content,
        provider: name,
        tokensUsed: chatCompletion.usage.totalTokens,
      );
    } catch (e) {
      AppLogger.error('OpenAI chat failed', e);
      throw AIException(
        message: 'OpenAI chat failed: $e',
        provider: name,
      );
    }
  }
}

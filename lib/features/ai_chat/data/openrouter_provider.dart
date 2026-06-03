// ─── OpenRouter Provider ──────────────────────────────────────────────
// OpenAI-compatible API via https://openrouter.ai (works on web + mobile).

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/logger.dart';
import 'ai_fallback_chain.dart';

class OpenRouterProvider implements AIProvider {
  final String _modelId;

  OpenRouterProvider({String? modelId})
      : _modelId = modelId ?? AppConfig.openRouterModelId;

  static const _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  @override
  String get name => 'OpenRouter ($_modelId)';

  String get _apiKey {
    final key = AppConfig.openRouterApiKey;
    if (key.isEmpty) {
      throw AIException(
        message: 'OpenRouter API key not configured',
        provider: 'OpenRouter',
      );
    }
    return key;
  }

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': AppConfig.openRouterHttpReferer,
        'X-Title': AppConfig.appName,
      };

  Future<Map<String, dynamic>> _post(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  String _extractContent(Map<String, dynamic> data) {
    final choices = data['choices'] as List?;
    if (choices == null || choices.isEmpty) return '';
    final message = choices.first['message'] as Map<String, dynamic>?;
    return message?['content'] as String? ?? '';
  }

  int? _extractTokens(Map<String, dynamic> data) {
    final usage = data['usage'] as Map<String, dynamic>?;
    return usage?['total_tokens'] as int?;
  }

  @override
  Future<AIResponse> generate(AIRequest request) async {
    try {
      final data = await _post({
        'model': _modelId,
        'messages': [
          {'role': 'user', 'content': request.prompt},
        ],
        'temperature': request.temperature,
        'max_tokens': request.maxTokens,
        'response_format': {'type': 'json_object'},
      });

      return AIResponse(
        content: _extractContent(data),
        provider: name,
        tokensUsed: _extractTokens(data),
        metadata: {'model': _modelId},
      );
    } catch (e) {
      AppLogger.error('OpenRouter generation failed', e);
      throw AIException(
        message: 'OpenRouter generation failed: $e',
        provider: name,
      );
    }
  }

  @override
  Future<AIResponse> chat(
    List<Map<String, String>> history,
    String message,
  ) async {
    try {
      final messages = history
          .map(
            (m) => {
              'role': m['role'] ?? 'user',
              'content': m['content'] ?? '',
            },
          )
          .toList();
      messages.add({'role': 'user', 'content': message});

      final data = await _post({
        'model': _modelId,
        'messages': messages,
        'temperature': 0.7,
      });

      return AIResponse(
        content: _extractContent(data),
        provider: name,
        tokensUsed: _extractTokens(data),
      );
    } catch (e) {
      AppLogger.error('OpenRouter chat failed', e);
      throw AIException(
        message: 'OpenRouter chat failed: $e',
        provider: name,
      );
    }
  }
}

// ─── Gemini Provider ────────────────────────────────────────────────
// AI Provider implementation for Google Gemini models.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import 'ai_fallback_chain.dart';

class GeminiProvider implements AIProvider {
  final String _modelId;

  GeminiProvider({String modelId = 'gemini-2.0-flash'}) : _modelId = modelId;

  @override
  String get name => 'Gemini ($_modelId)';

  String get _apiKey {
    final key = AppConfig.geminiApiKey;
    if (key.isEmpty || key == 'your-gemini-key') {
      throw AIException(
        message: 'Gemini API key not configured',
        provider: 'Gemini',
      );
    }
    return key;
  }

  @override
  Future<AIResponse> generate(AIRequest request) async {
    try {
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$_modelId:generateContent?key=$_apiKey');

      final body = {
        'contents': [
          {
            'parts': [
              {'text': request.prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': request.temperature,
          'maxOutputTokens': request.maxTokens,
          'responseMimeType': 'application/json',
        }
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final content =
          data['candidates'][0]['content']['parts'][0]['text'] as String;

      return AIResponse(
        content: content,
        provider: name,
        metadata: {
          'model': _modelId,
        },
      );
    } catch (e) {
      AppLogger.error('Gemini generation failed', e);
      throw AIException(
        message: 'Gemini generation failed: $e',
        provider: name,
      );
    }
  }

  @override
  Future<AIResponse> chat(
      List<Map<String, String>> history, String message) async {
    try {
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$_modelId:generateContent?key=$_apiKey');

      final contents = history.map((m) {
        return {
          'role': m['role'] == 'user' ? 'user' : 'model',
          'parts': [
            {'text': m['content']}
          ]
        };
      }).toList();

      contents.add({
        'role': 'user',
        'parts': [
          {'text': message}
        ]
      });

      final body = {
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
        }
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final content =
          data['candidates'][0]['content']['parts'][0]['text'] as String;

      return AIResponse(
        content: content,
        provider: name,
      );
    } catch (e) {
      AppLogger.error('Gemini chat failed', e);
      throw AIException(
        message: 'Gemini chat failed: $e',
        provider: name,
      );
    }
  }
}

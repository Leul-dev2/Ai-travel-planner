// ─── Cohere AI Provider ─────────────────────────────────────────────
// Primary AI provider using Cohere Command-R for chat and generation.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/logger.dart';
import 'ai_fallback_chain.dart';

class CohereProvider implements AIProvider {
  final String apiKey;
  static const String _baseUrl = 'https://api.cohere.com/v2';
  static const String _model = 'command-r-plus-08-2024';

  CohereProvider({required this.apiKey});

  @override
  String get name => 'Cohere';

  @override
  Future<AIResponse> generate(AIRequest request) async {
    if (apiKey.isEmpty) {
      throw AIException(message: 'Cohere API key not configured', provider: name);
    }

    const systemPrompt = '''You are an expert AI travel planner. Generate detailed, 
realistic travel itineraries in valid JSON format. Each response must be a JSON array 
of day objects with this exact structure:
[
  {
    "dayNumber": 1,
    "title": "Arrival & City Center",
    "activities": [
      {
        "name": "Activity Name",
        "time": "09:00",
        "duration": 120,
        "category": "attraction",
        "estimatedCost": 25.0,
        "description": "Brief description"
      }
    ]
  }
]
Categories: hotel, restaurant, attraction, transport, activity.
Return ONLY the JSON array, no markdown, no explanation.''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': request.prompt},
          ],
          'max_tokens': request.maxTokens,
          'temperature': request.temperature,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['message']['content'][0]['text'] as String? ?? '';
        final usage = data['usage'] as Map<String, dynamic>?;
        final tokens = (usage?['tokens'] as Map<String, dynamic>?)?['output_tokens'] as int?;

        AppLogger.info('Cohere generate success, tokens: $tokens');
        return AIResponse(content: content, provider: name, tokensUsed: tokens);
      } else if (response.statusCode == 429) {
        throw AIException(message: 'Cohere rate limit exceeded', provider: name);
      } else {
        final body = jsonDecode(response.body);
        throw AIException(
          message: 'Cohere error ${response.statusCode}: ${body['message'] ?? response.body}',
          provider: name,
        );
      }
    } on AIException {
      rethrow;
    } catch (e) {
      throw AIException(message: 'Cohere network error: $e', provider: name);
    }
  }

  @override
  Future<AIResponse> chat(
      List<Map<String, String>> history, String message) async {
    if (apiKey.isEmpty) {
      throw AIException(message: 'Cohere API key not configured', provider: name);
    }

    const systemPrompt = '''You are Wander, an expert AI travel copilot built into 
the Wanderlust travel app. You help users plan trips, discover destinations, manage 
budgets, and get travel advice. Be concise, helpful, and enthusiastic about travel. 
Use emojis sparingly for warmth. Format lists with bullet points when appropriate.''';

    // Build messages array from history
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      ...history,
      {'role': 'user', 'content': message},
    ];

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 1024,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['message']['content'][0]['text'] as String? ?? '';
        return AIResponse(content: content, provider: name);
      } else if (response.statusCode == 429) {
        throw AIException(message: 'Cohere rate limit exceeded', provider: name);
      } else {
        final body = jsonDecode(response.body);
        throw AIException(
          message: 'Cohere chat error ${response.statusCode}: ${body['message'] ?? response.body}',
          provider: name,
        );
      }
    } on AIException {
      rethrow;
    } catch (e) {
      throw AIException(message: 'Cohere chat network error: $e', provider: name);
    }
  }
}

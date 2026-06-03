// ─── AI Fallback Chain ──────────────────────────────────────────────
// Orchestrates AI providers with automatic fallback.
// Chain: OpenAI GPT → Gemini → Local Rules → Cached Plans

import '../../../core/errors/exceptions.dart';
import '../../../core/utils/logger.dart';

// ── AI Response ──
class AIResponse {
  final String content;
  final String provider;
  final int? tokensUsed;
  final Duration? latency;
  final Map<String, dynamic>? metadata;

  const AIResponse({
    required this.content,
    required this.provider,
    this.tokensUsed,
    this.latency,
    this.metadata,
  });
}

// ── AI Request ──
class AIRequest {
  final String prompt;
  final Map<String, dynamic>? context;
  final int maxTokens;
  final double temperature;

  const AIRequest({
    required this.prompt,
    this.context,
    this.maxTokens = 4096,
    this.temperature = 0.7,
  });
}

// ── Abstract AI Provider ──
abstract class AIProvider {
  String get name;
  Future<AIResponse> generate(AIRequest request);
  Future<AIResponse> chat(List<Map<String, String>> history, String message);
}

// ── Fallback Chain ──
class AIFallbackChain {
  final List<AIProvider> _providers;
  final Duration timeout;

  AIFallbackChain({
    required List<AIProvider> providers,
    this.timeout = const Duration(seconds: 30),
  }) : _providers = providers;

  /// Execute the request through the fallback chain.
  /// Tries each provider in order until one succeeds.
  Future<AIResponse> execute(AIRequest request) async {
    final errors = <String>[];

    for (final provider in _providers) {
      try {
        AppLogger.info('AI Chain: Trying ${provider.name}...');
        final stopwatch = Stopwatch()..start();

        final response = await provider
            .generate(request)
            .timeout(timeout, onTimeout: () {
          throw AIException(
            message: '${provider.name} timed out after ${timeout.inSeconds}s',
            provider: provider.name,
          );
        });

        stopwatch.stop();
        AppLogger.info(
          'AI Chain: ${provider.name} succeeded in ${stopwatch.elapsedMilliseconds}ms',
        );

        return AIResponse(
          content: response.content,
          provider: response.provider,
          tokensUsed: response.tokensUsed,
          latency: stopwatch.elapsed,
          metadata: response.metadata,
        );
      } on AIException catch (e) {
        AppLogger.warning('AI Chain: ${provider.name} failed — ${e.message}');
        errors.add('${provider.name}: ${e.message}');
        continue;
      } catch (e) {
        AppLogger.warning('AI Chain: ${provider.name} error — $e');
        errors.add('${provider.name}: $e');
        continue;
      }
    }

    // All providers failed
    AppLogger.error('AI Chain: All providers exhausted', errors.join('\n'));
    throw AIException(
      message: 'All AI providers failed. Errors: ${errors.join('; ')}',
      provider: 'fallback_chain',
    );
  }

  /// Execute a chat request through the fallback chain.
  Future<AIResponse> executeChat(
    List<Map<String, String>> history,
    String message,
  ) async {
    final errors = <String>[];

    for (final provider in _providers) {
      try {
        AppLogger.info('AI Chat Chain: Trying ${provider.name}...');
        final stopwatch = Stopwatch()..start();

        final response = await provider
            .chat(history, message)
            .timeout(timeout);

        stopwatch.stop();
        AppLogger.info(
          'AI Chat Chain: ${provider.name} succeeded in ${stopwatch.elapsedMilliseconds}ms',
        );

        return AIResponse(
          content: response.content,
          provider: response.provider,
          tokensUsed: response.tokensUsed,
          latency: stopwatch.elapsed,
        );
      } catch (e) {
        AppLogger.warning('AI Chat Chain: ${provider.name} failed — $e');
        errors.add('${provider.name}: $e');
        continue;
      }
    }

    throw AIException(
      message: 'All AI chat providers failed',
      provider: 'fallback_chain',
    );
  }
}

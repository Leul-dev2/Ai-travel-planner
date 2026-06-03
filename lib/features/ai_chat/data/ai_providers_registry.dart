import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import 'ai_fallback_chain.dart';
import 'cohere_provider.dart';
import 'gemini_provider.dart';
import 'local_rule_based_provider.dart';
import 'openai_provider.dart';
import 'openrouter_provider.dart';

/// Builds the ordered AI provider chain.
/// Priority: Cohere → OpenRouter → OpenAI → Gemini → LocalRules
List<AIProvider> buildDefaultAiProviders() {
  final providers = <AIProvider>[];

  // 1. Cohere Command-R+ (PRIMARY)
  if (AppConfig.cohereEnabled) {
    providers.add(CohereProvider(apiKey: AppConfig.cohereApiKey));
  }

  // 2. OpenRouter (fallback)
  if (AppConfig.openRouterApiKey.isNotEmpty) {
    providers.add(OpenRouterProvider());
  }

  // 3. OpenAI (fallback)
  if (!kIsWeb && AppConfig.openAiApiKey.isNotEmpty) {
    providers.add(OpenAIProvider());
  }

  // 4. Gemini (fallback)
  if (AppConfig.geminiEnabled) {
    providers.add(GeminiProvider(modelId: AppConfig.geminiModelId));
  }

  // 5. Local rules (always available — offline)
  providers.add(LocalRuleBasedProvider());

  return providers;
}

final aiFallbackChainProvider = Provider<AIFallbackChain>((ref) {
  return AIFallbackChain(
    providers: buildDefaultAiProviders(),
    timeout: const Duration(seconds: 90),
  );
});

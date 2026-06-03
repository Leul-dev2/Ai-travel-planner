// ─── Local Rule-Based Generator ─────────────────────────────────────
// Emergency fallback when all AI APIs are unavailable.
// Returns JSON matching trip_repository itinerary parser.

import 'dart:convert';

import 'ai_fallback_chain.dart';

class LocalRuleBasedProvider implements AIProvider {
  @override
  String get name => 'LocalRules';

  static const Map<String, List<String>> _activityTemplates = {
    'beaches': [
      'Morning beach walk and sunrise viewing',
      'Snorkeling or swimming at the coast',
      'Beachside lunch at a local seafood restaurant',
      'Sunset cocktails at a beach bar',
    ],
    'museums': [
      'Visit the National Museum',
      'Explore local art gallery',
      'Historical city walking tour',
      'Cultural heritage center visit',
    ],
    'hiking': [
      'Early morning nature trail hike',
      'Mountain viewpoint excursion',
      'Waterfall trail exploration',
      'National park guided walk',
    ],
    'food': [
      'Local street food breakfast tour',
      'Traditional cooking class',
      'Market visit and ingredient shopping',
      'Fine dining dinner experience',
    ],
    'nightlife': [
      'Rooftop bar with city views',
      'Live music venue',
      'Local nightlife district exploration',
      'Late-night street food',
    ],
    'shopping': [
      'Local market and bazaar visit',
      'Artisan craft shops',
      'Mall or shopping district tour',
      'Souvenir shopping',
    ],
    'culture': [
      'Visit ancient temples or churches',
      'Attend a traditional dance show',
      'Local village experience',
      'Historical monument tour',
    ],
    'adventure': [
      'Zip-lining or paragliding',
      'White-water rafting',
      'Rock climbing experience',
      'ATV or off-road adventure',
    ],
    'nature': [
      'Botanical garden visit',
      'Bird watching excursion',
      'Lake or river boat trip',
      'Wildlife sanctuary visit',
    ],
  };

  static const List<String> _defaultActivities = [
    'City exploration and sightseeing',
    'Local restaurant for lunch',
    'Free time for personal exploration',
    'Dinner at a recommended restaurant',
  ];

  int _durationFromContext(Map<String, dynamic> context) {
    final d = (context['duration'] as int?) ?? 0;
    return d < 1 ? 3 : d;
  }

  @override
  Future<AIResponse> generate(AIRequest request) async {
    final context = Map<String, dynamic>.from(request.context ?? {});
    final destination = context['city'] as String? ?? 'Your destination';
    final country = context['country'] as String? ?? '';
    final duration = _durationFromContext(context);
    final interests = List<String>.from(context['interests'] as List? ?? []);

    final days = <Map<String, dynamic>>[];

    for (int day = 1; day <= duration; day++) {
      final dayActivities = <String>[];
      if (interests.isNotEmpty) {
        final interest = interests[(day - 1) % interests.length];
        dayActivities.addAll(
          _activityTemplates[interest] ?? _defaultActivities,
        );
      } else {
        dayActivities.addAll(_defaultActivities);
      }

      final activities = <Map<String, dynamic>>[];
      for (int i = 0; i < dayActivities.length; i++) {
        final hour = 8 + (i * 3);
        activities.add({
          'name': dayActivities[i],
          'time': '${hour.toString().padLeft(2, '0')}:00',
          'duration': 120,
          'category': 'attraction',
          'estimatedCost': 25.0,
          'description':
              'Offline plan for $destination${country.isNotEmpty ? ', $country' : ''}.',
        });
      }

      days.add({
        'dayNumber': day,
        'title': 'Day $day in $destination',
        'activities': activities,
      });
    }

    return AIResponse(
      content: jsonEncode(days),
      provider: name,
      metadata: {
        'type': 'rule_based',
        'destination': destination,
        'duration': duration,
      },
    );
  }

  @override
  Future<AIResponse> chat(
      List<Map<String, String>> history, String message) async {
    final lower = message.toLowerCase();

    String response;
    if (lower.contains('visa')) {
      response = 'For visa information, I recommend checking your destination '
          'country\'s official embassy website or a service like iVisa.com. '
          'Requirements vary by your nationality and destination.';
    } else if (lower.contains('budget') || lower.contains('cost')) {
      response = 'Budget tips:\n'
          '• Backpacker: \$30-50/day\n'
          '• Mid-range: \$80-150/day\n'
          '• Luxury: \$200+/day\n\n'
          'These vary significantly by destination. Southeast Asia and '
          'Africa tend to be more affordable, while Western Europe and '
          'Japan are more expensive.';
    } else if (lower.contains('pack') || lower.contains('bring')) {
      response = 'Essential packing list:\n'
          '• Passport & copies\n'
          '• Universal power adapter\n'
          '• Comfortable walking shoes\n'
          '• Weather-appropriate clothing\n'
          '• First aid kit\n'
          '• Reusable water bottle\n'
          '• Portable charger';
    } else if (lower.contains('safety') || lower.contains('safe')) {
      response = 'Travel safety tips:\n'
          '• Register with your embassy\n'
          '• Keep copies of important documents\n'
          '• Use hotel safes for valuables\n'
          '• Be aware of common scams\n'
          '• Share your itinerary with someone at home\n'
          '• Get travel insurance';
    } else {
      response = 'I\'m currently in offline mode with limited capabilities. '
          'I can help with general travel tips about visas, budgets, packing, '
          'and safety. For detailed trip planning, please try again when '
          'you have an internet connection.';
    }

    return AIResponse(content: response, provider: name);
  }
}

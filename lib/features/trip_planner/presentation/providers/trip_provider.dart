// ─── Trip Riverpod Providers ────────────────────────────────────────
// State management for trip planning and management.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai_chat/data/ai_fallback_chain.dart';
import '../../../ai_chat/data/gemini_provider.dart';
import '../../../ai_chat/data/local_rule_based_provider.dart';
import '../../../ai_chat/data/openai_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/trip_remote_datasource.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trip_repository.dart';

// ── Datasource Provider ──
final tripRemoteDatasourceProvider = Provider<TripRemoteDatasource>((ref) {
  return TripRemoteDatasourceImpl();
});

// ── AI Fallback Chain ──
final aiFallbackChainProvider = Provider<AIFallbackChain>((ref) {
  return AIFallbackChain(
    providers: [
      OpenAIProvider(),
      GeminiProvider(),
      LocalRuleBasedProvider(),
    ],
  );
});

// ── Trip Repository ──
final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final authState = ref.watch(authStateProvider);
  return TripRepositoryImpl(
    remoteDatasource: ref.watch(tripRemoteDatasourceProvider),
    aiFallbackChain: ref.watch(aiFallbackChainProvider),
    networkInfo: ref.watch(networkInfoProvider),
    currentUserId: authState.user?.id ?? '',
  );
});

// ── My Trips ──
final myTripsProvider =
    FutureProvider.autoDispose<List<TripEntity>>((ref) async {
  final repo = ref.watch(tripRepositoryProvider);
  final result = await repo.getMyTrips();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (trips) => trips,
  );
});

// ── Single Trip ──
final tripDetailProvider =
    FutureProvider.family.autoDispose<TripEntity, String>((ref, tripId) async {
  final repo = ref.watch(tripRepositoryProvider);
  final result = await repo.getTripById(tripId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (trip) => trip,
  );
});

// ── Trip Form State ──
final tripFormProvider =
    StateNotifierProvider.autoDispose<TripFormNotifier, TripFormData>((ref) {
  return TripFormNotifier();
});

class TripFormNotifier extends StateNotifier<TripFormData> {
  TripFormNotifier() : super(TripFormData());

  void setCountry(String country) => state = state.copyWith(country: country);
  void setCity(String city) => state = state.copyWith(city: city);

  void setDates(DateTime departure, DateTime returnDate) {
    state = state.copyWith(
      departureDate: departure,
      returnDate: returnDate,
      duration: returnDate.difference(departure).inDays,
    );
  }

  void setTripType(String type) => state = state.copyWith(tripType: type);

  void setInterests(List<String> interests) =>
      state = state.copyWith(interests: interests);

  void toggleInterest(String interest) {
    final current = List<String>.from(state.interests);
    if (current.contains(interest)) {
      current.remove(interest);
    } else {
      current.add(interest);
    }
    state = state.copyWith(interests: current);
  }

  void setBudget({double? amount, String? currency, String? category}) {
    state = state.copyWith(
      budgetAmount: amount,
      budgetCurrency: currency,
      budgetCategory: category,
    );
  }

  void setTravelerCount(int count) =>
      state = state.copyWith(numberOfTravelers: count);

  void setTransportPreference(String preference) =>
      state = state.copyWith(transportPreference: preference);

  void reset() => state = TripFormData();
}

// ── Wizard Step ──
final wizardStepProvider = StateProvider.autoDispose<int>((ref) => 0);

// ── AI Generation ──
final generateItineraryProvider = FutureProvider.family
    .autoDispose<List<ItineraryDayEntity>, TripFormData>((ref, formData) async {
  final repo = ref.read(tripRepositoryProvider);
  final result = await repo.generateItinerary(formData);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (days) => days,
  );
});

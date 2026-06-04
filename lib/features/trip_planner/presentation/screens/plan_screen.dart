import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/widgets/utils/keep_alive_wrapper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/trip_entity.dart';
import '../providers/trip_provider.dart';
import '../widgets/step_1_destination.dart';
import '../widgets/step_2_details.dart';
import '../widgets/step_3_interests.dart';
import '../widgets/step_4_budget.dart';
import '../../../subscriptions/presentation/providers/entitlement_provider.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final GlobalKey<Step1DestinationState> _step1Key =
      GlobalKey<Step1DestinationState>();

  late AnimationController _progressCtrl;

  static const _stepLabels = ['Destination', 'Details', 'Interests', 'Budget'];
  static const _stepIcons = [
    Icons.location_on_rounded,
    Icons.tune_rounded,
    Icons.favorite_rounded,
    Icons.account_balance_wallet_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  bool _validateStep1() {
    // Commit text controller state first
    _step1Key.currentState?.commitToProvider();

    final form = ref.read(tripFormProvider);
    if (form.country.trim().isEmpty || form.city.trim().isEmpty) {
      _showError('Please enter both a country and city.');
      return false;
    }
    if (form.departureDate == null || form.returnDate == null) {
      _showError('Please select your travel dates.');
      return false;
    }
    return true;
  }

  void _showError(String msg) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
      ),
    );
  }

  void _nextStep() {
    final currentStep = ref.read(wizardStepProvider);
    if (currentStep == 0 && !_validateStep1()) return;
    if (currentStep < 3) {
      HapticFeedback.selectionClick();
      ref.read(wizardStepProvider.notifier).state = currentStep + 1;
      _pageController.animateToPage(
        currentStep + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _generateItinerary();
    }
  }

  void _prevStep() {
    final currentStep = ref.read(wizardStepProvider);
    if (currentStep > 0) {
      HapticFeedback.selectionClick();
      ref.read(wizardStepProvider.notifier).state = currentStep - 1;
      _pageController.animateToPage(
        currentStep - 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _generateItinerary() async {
    if (!_validateStep1()) return;

    final formData = ref.read(tripFormProvider);
    final entitlement = ref.read(entitlementProvider).value;

    // Feature Gate: Free users can only generate up to 3 days
    if (entitlement != null && !entitlement.isProOrHigher && formData.duration > 3) {
      context.push(RouteNames.paywall);
      _showError('Free plan is limited to 3-day trips. Upgrade to Pro!');
      return;
    }

    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.auroraGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 30),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.08, 1.08),
                    duration: 800.ms,
                  ),
              const SizedBox(height: 20),
              Text(
                'AI is crafting your\nperfect itinerary...',
                textAlign: TextAlign.center,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimaryDark,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${formData.city}, ${formData.country} • ${formData.duration} days',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textMutedDark),
              ),
              const SizedBox(height: 20),
              const LinearProgressIndicator(
                backgroundColor: AppColors.surfaceAltDark,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final days = await ref.read(generateItineraryProvider(formData).future);
      if (!mounted) return;
      navigator.pop();

      final ownerId = ref.read(authStateProvider).user?.id ?? '';
      final trip = TripEntity(
        id: 'draft_trip_${DateTime.now().millisecondsSinceEpoch}',
        ownerId: ownerId,
        title: 'Trip to ${formData.city}',
        destination:
            DestinationEntity(country: formData.country, city: formData.city),
        departureDate: formData.departureDate!,
        returnDate: formData.returnDate!,
        duration: formData.duration,
        tripType: formData.tripType,
        interests: formData.interests,
        budget: BudgetEntity(
          amount: formData.budgetAmount,
          currency: formData.budgetCurrency,
          category: formData.budgetCategory,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        itinerary: days,
      );

      ref.read(tripFormProvider.notifier).reset();
      ref.read(wizardStepProvider.notifier).state = 0;
      router.push(RouteNames.itineraryPath(trip.id), extra: trip);
    } catch (e) {
      if (!mounted) return;
      navigator.pop();
      _showError('Failed to generate itinerary. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(wizardStepProvider);
    // Keep the trip form provider alive for the duration of the PlanScreen
    ref.watch(tripFormProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ── Premium Step Header ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  // Back + step label
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _prevStep,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAltDark,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMD),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: const Icon(Icons.chevron_left_rounded,
                              color: AppColors.textPrimaryDark, size: 22),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STEP ${currentStep + 1} OF 4',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textMutedDark,
                                letterSpacing: 1.5,
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text(
                                _stepLabels[currentStep],
                                key: ValueKey(currentStep),
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.textPrimaryDark,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Step icon
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          key: ValueKey(currentStep),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppColors.auroraGradient,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMD),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(_stepIcons[currentStep],
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Progress dots
                  Row(
                    children: List.generate(4, (index) {
                      final isDone = index < currentStep;
                      final isActive = index == currentStep;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: index < 3 ? 6 : 0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: (isDone || isActive)
                                  ? AppColors.auroraGradient
                                  : null,
                              color: (!isDone && !isActive)
                                  ? AppColors.surfaceAltDark
                                  : null,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.5),
                                        blurRadius: 8,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 8),

            // ── Page View ──
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildCinematicStep(Step1Destination(key: _step1Key)),
                  KeepAliveWrapper(child: _buildCinematicStep(const Step2Details())),
                  KeepAliveWrapper(child: _buildCinematicStep(const Step3Interests())),
                  KeepAliveWrapper(child: _buildCinematicStep(const Step4Budget())),
                ],
              ),
            ),

            // ── Bottom CTA ──
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                border: Border(
                  top: BorderSide(
                      color: AppColors.glassBorder.withValues(alpha: 0.4)),
                ),
              ),
              child: PrimaryButton(
                label: currentStep == 3
                    ? '✨ Generate My Itinerary'
                    : 'Continue',
                icon: currentStep == 3 ? null : Icons.arrow_forward_rounded,
                onTap: _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCinematicStep(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

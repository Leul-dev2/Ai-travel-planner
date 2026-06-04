import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/trip_provider.dart';

class Step4Budget extends ConsumerWidget {
  const Step4Budget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(tripFormProvider);

    // Determine color based on budget level
    Color budgetColor = AppColors.primary;
    if (formData.budgetAmount > 5000) {
      budgetColor = AppColors.secondary; // Luxury
    } else if (formData.budgetAmount > 2000) {
      budgetColor = AppColors.accent; // Comfort
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set your budget.',
          style: AppTypography.displaySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'How much do you plan to spend?',
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textMutedDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        const SectionLabel('Total Budget Estimate'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: budgetColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMutedDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$',
                            style: AppTypography.titleMedium.copyWith(
                              color: budgetColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${formData.budgetAmount.toInt()}',
                            style: AppTypography.displayMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: budgetColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(color: budgetColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      formData.budgetCategory.toUpperCase(),
                      style: AppTypography.labelMedium.copyWith(
                        color: budgetColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6,
                  activeTrackColor: budgetColor,
                  inactiveTrackColor: AppColors.surfaceAltDark,
                  thumbColor: Colors.white,
                  overlayColor: budgetColor.withValues(alpha: 0.2),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                ),
                child: Slider(
                  value: formData.budgetAmount,
                  min: 100,
                  max: 10000,
                  divisions: 99,
                  onChanged: (value) {
                    String category = 'Economy';
                    if (value > 2000) category = 'Comfort';
                    if (value > 5000) category = 'Luxury';

                    ref.read(tripFormProvider.notifier).setBudget(
                          amount: value,
                          category: category,
                          currency: formData.budgetCurrency,
                        );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$100', style: AppTypography.labelSmall.copyWith(color: AppColors.textMutedDark)),
                  Text('\$10,000+', style: AppTypography.labelSmall.copyWith(color: AppColors.textMutedDark)),
                ],
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 40),
        const SectionLabel('Preferred Transport'),
        const SizedBox(height: 16),
        _TransportSelector(
          currentPref: formData.transportPreference ?? 'public_transport',
          onSelect: (val) {
            ref.read(tripFormProvider.notifier).setTransportPreference(val);
          },
        ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
      ],
    );
  }
}

class _TransportSelector extends StatelessWidget {
  final String currentPref;
  final ValueChanged<String> onSelect;

  const _TransportSelector({
    required this.currentPref,
    required this.onSelect,
  });

  static const _options = [
    {'id': 'public_transport', 'label': 'Transit', 'icon': Icons.train_rounded},
    {'id': 'car_rental', 'label': 'Car Rental', 'icon': Icons.directions_car_rounded},
    {'id': 'taxi_rideshare', 'label': 'Rideshare', 'icon': Icons.local_taxi_rounded},
    {'id': 'walking', 'label': 'Walking', 'icon': Icons.directions_walk_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildOption(_options[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildOption(_options[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildOption(_options[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildOption(_options[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildOption(Map<String, dynamic> opt) {
    final isSelected = currentPref == opt['id'];
    return GestureDetector(
      onTap: () => onSelect(opt['id'] as String),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceAltDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderDark,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              opt['icon'] as IconData,
              color: isSelected ? AppColors.primary : AppColors.textMutedDark,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              opt['label'] as String,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondaryDark,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

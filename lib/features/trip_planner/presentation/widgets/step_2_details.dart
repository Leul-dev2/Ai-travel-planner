import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/trip_provider.dart';

class Step2Details extends ConsumerWidget {
  const Step2Details({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(tripFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScreenHeader(
          line1: 'TRIP',
          line2: 'DETAILS.',
          subtitle: 'Step 2: Travel Style',
        ),
        const SizedBox(height: 32),
        const SectionLabel('Trip Type'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: AppConstants.tripTypes.map((type) {
            final isSelected = formData.tripType == type;

            return ChoiceChip(
              label: Text(type[0].toUpperCase() + type.substring(1)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(tripFormProvider.notifier).setTripType(type);
                }
              },
              backgroundColor: AppColors.surfaceAltDark,
              selectedColor: AppColors.primaryContainer,
              labelStyle: AppTypography.labelMedium.copyWith(
                color:
                    isSelected ? AppColors.primary : AppColors.textPrimaryDark,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.borderDark,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        const SectionLabel('Number of Travelers'),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${formData.numberOfTravelers} Traveler${formData.numberOfTravelers > 1 ? 's' : ''}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: formData.numberOfTravelers > 1
                        ? () => ref
                            .read(tripFormProvider.notifier)
                            .setTravelerCount(formData.numberOfTravelers - 1)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: AppColors.primary,
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(tripFormProvider.notifier)
                        .setTravelerCount(formData.numberOfTravelers + 1),
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

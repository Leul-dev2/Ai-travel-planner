import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/trip_provider.dart';

class Step3Interests extends ConsumerWidget {
  const Step3Interests({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(tripFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScreenHeader(
          line1: 'YOUR',
          line2: 'INTERESTS.',
          subtitle: 'Step 3: What do you love?',
        ),
        const SizedBox(height: 32),
        const SectionLabel('Select Multiple'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: AppConstants.interests.map((interest) {
            final isSelected = formData.interests.contains(interest);

            return FilterChip(
              label: Text(interest[0].toUpperCase() + interest.substring(1).replaceAll('_', ' ')),
              selected: isSelected,
              onSelected: (_) {
                ref.read(tripFormProvider.notifier).toggleInterest(interest);
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
      ],
    );
  }
}

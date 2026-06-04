import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/trip_provider.dart';

class Step2Details extends ConsumerWidget {
  const Step2Details({super.key});

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'leisure': return Icons.weekend_rounded;
      case 'adventure': return Icons.hiking_rounded;
      case 'cultural': return Icons.museum_rounded;
      case 'business': return Icons.work_rounded;
      case 'romantic': return Icons.favorite_rounded;
      case 'family': return Icons.family_restroom_rounded;
      default: return Icons.flight_takeoff_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(tripFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who is traveling?',
          style: AppTypography.displaySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Tell us about your travel style.',
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textMutedDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        const SectionLabel('Trip Type'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: AppConstants.tripTypes.length,
          itemBuilder: (context, index) {
            final type = AppConstants.tripTypes[index];
            final isSelected = formData.tripType == type;

            return GestureDetector(
              onTap: () => ref.read(tripFormProvider.notifier).setTripType(type),
              child: AnimatedContainer(
                duration: AppTheme.durationMedium,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? AppColors.auroraGradient
                      : const LinearGradient(
                          colors: [
                            AppColors.surfaceAltDark,
                            AppColors.surfaceAltDark,
                          ],
                        ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.borderDark,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIconForType(type),
                      color: isSelected ? Colors.white : AppColors.textMutedDark,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type[0].toUpperCase() + type.substring(1),
                      style: AppTypography.labelLarge.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimaryDark,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: Duration(milliseconds: index * 50)).fadeIn().slideY(begin: 0.1);
          },
        ),
        const SizedBox(height: 40),
        const SectionLabel('Number of Travelers'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Travelers',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMutedDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formData.numberOfTravelers} Person${formData.numberOfTravelers > 1 ? 's' : ''}',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: formData.numberOfTravelers > 1
                        ? () => ref
                            .read(tripFormProvider.notifier)
                            .setTravelerCount(formData.numberOfTravelers - 1)
                        : null,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: formData.numberOfTravelers > 1
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.surfaceAltDark,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Icon(
                        Icons.remove_rounded,
                        color: formData.numberOfTravelers > 1
                            ? AppColors.primary
                            : AppColors.textMutedDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => ref
                        .read(tripFormProvider.notifier)
                        .setTravelerCount(formData.numberOfTravelers + 1),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.auroraGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),
      ],
    );
  }
}

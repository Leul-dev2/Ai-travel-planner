import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/trip_provider.dart';

class Step3Interests extends ConsumerWidget {
  const Step3Interests({super.key});

  IconData _getIconForInterest(String interest) {
    switch (interest.toLowerCase()) {
      case 'history': return Icons.account_balance_rounded;
      case 'food': return Icons.restaurant_rounded;
      case 'nature': return Icons.park_rounded;
      case 'nightlife': return Icons.nightlife_rounded;
      case 'art': return Icons.palette_rounded;
      case 'shopping': return Icons.shopping_bag_rounded;
      case 'relaxation': return Icons.spa_rounded;
      case 'sports': return Icons.sports_basketball_rounded;
      default: return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(tripFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What do you love?',
          style: AppTypography.displaySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Select your top interests for this trip.',
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textMutedDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        const SectionLabel('Select Multiple (Optional)'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: AppConstants.interests.length,
          itemBuilder: (context, index) {
            final interest = AppConstants.interests[index];
            final isSelected = formData.interests.contains(interest);

            return GestureDetector(
              onTap: () {
                ref.read(tripFormProvider.notifier).toggleInterest(interest);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surfaceAltDark,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderDark,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppColors.auroraGradient
                            : const LinearGradient(
                                colors: [
                                  AppColors.surfaceElevatedDark,
                                  AppColors.surfaceElevatedDark,
                                ],
                              ),
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                )
                              ]
                            : null,
                      ),
                      child: Icon(
                        _getIconForInterest(interest),
                        color: isSelected ? Colors.white : AppColors.textMutedDark,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      interest[0].toUpperCase() + interest.substring(1).replaceAll('_', ' '),
                      style: AppTypography.labelLarge.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimaryDark,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: Duration(milliseconds: index * 50)).fadeIn().scale(begin: const Offset(0.9, 0.9));
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/trip_provider.dart';

class Step4Budget extends ConsumerWidget {
  const Step4Budget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(tripFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScreenHeader(
          line1: 'BUDGET &',
          line2: 'TRANSPORT.',
          subtitle: 'Step 4: Final details',
        ),
        const SizedBox(height: 32),
        const SectionLabel('Total Budget Estimate'),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${formData.budgetAmount.toInt()} ${formData.budgetCurrency}',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formData.budgetCategory.toUpperCase(),
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textMutedDark,
                    ),
                  ),
                ],
              ),
              Slider(
                value: formData.budgetAmount,
                min: 100,
                max: 10000,
                divisions: 99,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.surfaceAltDark,
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
            ],
          ),
        ),
        const SizedBox(height: 32),
        const SectionLabel('Preferred Transport'),
        const SizedBox(height: 12),
        AppDropdown(
          label: 'Transport Preference',
          value: formData.transportPreference ?? 'public_transport',
          items: const [
            DropdownMenuItem(
                value: 'public_transport', child: Text('Public Transport')),
            DropdownMenuItem(value: 'car_rental', child: Text('Car Rental')),
            DropdownMenuItem(
                value: 'taxi_rideshare', child: Text('Taxi / Ride-share')),
            DropdownMenuItem(value: 'walking', child: Text('Walking mainly')),
          ],
          onChanged: (value) {
            if (value != null) {
              ref
                  .read(tripFormProvider.notifier)
                  .setTransportPreference(value);
            }
          },
        ),
      ],
    );
  }
}

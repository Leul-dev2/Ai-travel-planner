// Placeholder — Budget Rejected Screen
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';

class BudgetRejectedScreen extends StatelessWidget {
  const BudgetRejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconActionButton(
                icon: Icons.chevron_left,
                label: 'Back',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 40),
              const ScreenHeader(
                line1: 'BUDGET',
                line2: 'CALIBRATION.',
                subtitle: 'Adjust your budget parameters',
              ),
              const Spacer(),
              const Center(child: AppLoader(label: 'Coming in Phase 4...')),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

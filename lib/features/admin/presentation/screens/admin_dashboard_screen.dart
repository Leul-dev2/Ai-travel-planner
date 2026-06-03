// Placeholder — Admin Dashboard Screen (will be fully implemented in Phase 11)
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

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
                line1: 'ADMIN',
                line2: 'PANEL.',
                subtitle: 'Platform management',
              ),
              const Spacer(),
              const Center(child: AppLoader(label: 'Coming in Phase 11...')),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

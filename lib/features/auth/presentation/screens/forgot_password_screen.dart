// ─── Forgot Password Screen ─────────────────────────────────────────
// Password reset flow via email.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.sendPasswordResetEmail(_emailCtrl.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (_) {
        setState(() => _emailSent = true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLG,
            vertical: AppTheme.spacingXL,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconActionButton(
                  icon: Icons.chevron_left,
                  label: 'Back',
                  onTap: () => context.go(RouteNames.login),
                ),
                const SizedBox(height: 40),
                const ScreenHeader(
                  line1: 'RESET',
                  line2: 'PASSWORD.',
                  subtitle: 'We\'ll send you a reset link',
                ),
                const SizedBox(height: 40),
                if (_emailSent)
                  GlassCard(
                    child: Column(
                      children: [
                        const Icon(Icons.mark_email_read,
                            color: AppColors.success, size: 48),
                        const SizedBox(height: 16),
                        const StatusChip(
                          icon: Icons.check_circle,
                          label: 'Reset link sent! Check your email inbox.',
                          color: AppColors.success,
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: 'Back to Login',
                          onTap: () => context.go(RouteNames.login),
                        ),
                      ],
                    ),
                  )
                else
                  GlassCard(
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Email Address',
                          hint: 'your@email.com',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 28),
                        PrimaryButton(
                          label: 'Send Reset Link',
                          icon: Icons.send,
                          onTap: _submit,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

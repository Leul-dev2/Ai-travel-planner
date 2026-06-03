// ─── Register Screen ────────────────────────────────────────────────
// New user registration with Riverpod + GoRouter.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final repo = ref.read(authRepositoryProvider);
    final authState = ref.read(authStateProvider);

    final result = await repo.registerWithEmail(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        authState.setError(failure.message);
      },
      (user) {
        authState.setUser(user);
        context.go(RouteNames.home);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

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
                const SizedBox(height: 48),
                const ScreenHeader(
                  line1: 'CREATE',
                  line2: 'ACCOUNT.',
                  subtitle: 'Start your travel journey',
                ),
                const SizedBox(height: 40),
                GlassCard(
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Full Name',
                        hint: 'Your full name',
                        controller: _nameCtrl,
                        textInputAction: TextInputAction.next,
                        validator: Validators.name,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Email Address',
                        hint: 'your@email.com',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Password',
                        hint: '••••••••',
                        controller: _passCtrl,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator: Validators.password,
                      ),
                      if (authState.error != null) ...[
                        const SizedBox(height: 16),
                        StatusChip(
                          icon: Icons.error_outline,
                          label: authState.error!,
                          color: AppColors.error,
                        ),
                      ],
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: 'Create Account',
                        icon: Icons.person_add,
                        onTap: _submit,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // ── Social Registration ──
                SocialButton(
                  provider: SocialProvider.google,
                  onTap: () async {
                    setState(() => _isLoading = true);
                    final repo = ref.read(authRepositoryProvider);
                    final auth = ref.read(authStateProvider);
                    final result = await repo.signInWithGoogle();
                    if (!mounted) return;
                    setState(() => _isLoading = false);
                    result.fold(
                      (f) => auth.setError(f.message),
                      (user) {
                        auth.setUser(user);
                        context.go(RouteNames.home);
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      authState.clearError();
                      context.go(RouteNames.login);
                    },
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMutedDark,
                        ),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'SIGN IN',
                            style: AppTypography.button.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
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

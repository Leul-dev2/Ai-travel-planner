// ─── Login Screen ───────────────────────────────────────────────────
// Email login with social sign-in options, using Riverpod + GoRouter.

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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final repo = ref.read(authRepositoryProvider);
    final authState = ref.read(authStateProvider);

    final result = await repo.loginWithEmail(
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

  Future<void> _submitGoogleSignIn() async {
    setState(() => _isLoading = true);

    final repo = ref.read(authRepositoryProvider);
    final authState = ref.read(authStateProvider);

    final result = await repo.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) => authState.setError(failure.message),
      (user) {
        authState.setUser(user);
        context.go(RouteNames.home);
      },
    );
  }

  Future<void> _submitGuestLogin() async {
    setState(() => _isLoading = true);

    final repo = ref.read(authRepositoryProvider);
    final authState = ref.read(authStateProvider);

    final result = await repo.signInAsGuest();

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) => authState.setError(failure.message),
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
                // Logo / brand
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(Icons.flight_takeoff,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'SMART TRAVEL AI',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                const ScreenHeader(
                  line1: 'WELCOME',
                  line2: 'BACK.',
                  subtitle: 'Sign in to continue your journey',
                ),
                const SizedBox(height: 40),

                // ── Login Form ──
                GlassCard(
                  child: Column(
                    children: [
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
                        onFieldSubmitted: (_) => _submitLogin(),
                        validator: (v) => Validators.required(v, 'Password'),
                      ),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              context.push(RouteNames.forgotPassword),
                          child: Text(
                            'FORGOT PASSWORD?',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      // Error display
                      if (authState.error != null) ...[
                        const SizedBox(height: 12),
                        StatusChip(
                          icon: Icons.error_outline,
                          label: authState.error!,
                          color: AppColors.error,
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Login button
                      PrimaryButton(
                        label: 'Sign In',
                        icon: Icons.arrow_forward,
                        onTap: _submitLogin,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Social Login ──
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: AppColors.borderDark),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textMutedDark,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: AppColors.borderDark),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SocialButton(
                  provider: SocialProvider.google,
                  onTap: _submitGoogleSignIn,
                ),
                const SizedBox(height: 12),
                SocialButton(
                  provider: SocialProvider.apple,
                  onTap: () {}, // TODO: Implement Apple Sign-In
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Continue as Guest',
                  icon: Icons.person_outline,
                  variant: ButtonVariant.ghost,
                  onTap: _submitGuestLogin,
                ),
                const SizedBox(height: 32),

                // ── Register link ──
                Center(
                  child: GestureDetector(
                    onTap: () {
                      authState.clearError();
                      context.go(RouteNames.register);
                    },
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMutedDark,
                        ),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'SIGN UP',
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

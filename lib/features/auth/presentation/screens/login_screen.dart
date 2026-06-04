// ─── Login Screen ───────────────────────────────────────────────────
// Cinematic login with fullscreen imagery and glassmorphism.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      (failure) => authState.setError(failure.message),
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
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background Imagery ──
          CachedNetworkImage(
            imageUrl: 'https://images.unsplash.com/photo-1518684079-3c830dcef090?q=80&w=1000', // Beautiful Dubai/Desert night vibe or Paris
            fit: BoxFit.cover,
          ).animate().fadeIn(duration: 1200.ms),

          // ── Gradient Overlay ──
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0xAA000000),
                  Color(0xFA000000),
                ],
                stops: [0.0, 0.4, 0.8],
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
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
                    const SizedBox(height: 40),
                    // Logo
                    Row(
                      children: [
                        const Icon(Icons.flight_takeoff, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'WANDER AI',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ).animate().fadeIn().slideX(begin: -0.1),
                    const SizedBox(height: 60),

                    Text(
                      'Welcome\nBack.',
                      style: AppTypography.displayMedium.copyWith(
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                    const SizedBox(height: 40),

                    // ── Form Glass Card ──
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      radius: AppTheme.radiusXXL,
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
                          
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push(RouteNames.forgotPassword),
                              child: Text(
                                'FORGOT PASSWORD?',
                                style: AppTypography.labelSmall.copyWith(color: AppColors.primaryLight),
                              ),
                            ),
                          ),

                          if (authState.error != null) ...[
                            const SizedBox(height: 12),
                            StatusChip(
                              icon: Icons.error_outline,
                              label: authState.error!,
                              color: AppColors.error,
                            ),
                          ],
                          const SizedBox(height: 24),

                          PrimaryButton(
                            label: 'Sign In',
                            onTap: _submitLogin,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                    const SizedBox(height: 32),

                    // ── Social Login ──
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.2))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: AppTypography.labelSmall.copyWith(color: Colors.white70),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.2))),
                      ],
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: SocialButton(
                            provider: SocialProvider.google,
                            onTap: _submitGoogleSignIn,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SocialButton(
                            provider: SocialProvider.apple,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Apple Sign-In coming soon!')),
                              );
                            },
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 600.ms),
                    
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Explore as Guest',
                      icon: Icons.explore,
                      variant: ButtonVariant.ghost,
                      onTap: _submitGuestLogin,
                    ).animate().fadeIn(delay: 700.ms),
                    
                    const SizedBox(height: 40),

                    // ── Register link ──
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          authState.clearError();
                          context.go(RouteNames.register);
                        },
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                            children: [
                              const TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: 'SIGN UP',
                                style: AppTypography.labelLarge.copyWith(color: AppColors.primaryLight),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

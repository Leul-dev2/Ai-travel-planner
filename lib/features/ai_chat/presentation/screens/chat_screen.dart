import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/chat_entity.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _typingCtrl;
  bool _hasText = false;

  static const _quickPrompts = [
    '🌍 Best budget destinations?',
    '🗺️ Plan Tokyo itinerary',
    '✈️ Tips for packing light',
    '🏨 Find luxury hotels in Bali',
    '💰 How to travel cheap in Europe?',
    '🌅 Best beaches in Southeast Asia',
  ];

  @override
  void initState() {
    super.initState();
    _typingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _controller.addListener(() {
      setState(() => _hasText = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _typingCtrl.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? text]) {
    final msg = text ?? _controller.text;
    if (msg.trim().isEmpty) return;
    HapticFeedback.selectionClick();
    ref.read(chatProvider.notifier).sendMessage(msg);
    if (text == null) _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final isLoading = ref.watch(chatProvider.notifier).isLoading;
    ref.listen(chatProvider, (_, __) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // ── Premium App Bar ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                border: Border(
                  bottom: BorderSide(
                      color: AppColors.glassBorder.withValues(alpha: 0.5)),
                ),
              ),
              child: Row(
                children: [
                  // AI Avatar
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppColors.auroraGradient,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMD),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 20),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .shimmer(duration: 2500.ms, color: Colors.white24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Wander AI',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.w800,
                            )),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isLoading ? 'Thinking...' : 'Online',
                              style: AppTypography.labelSmall.copyWith(
                                color: isLoading
                                    ? AppColors.accentWarm
                                    : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Clear button
                  if (messages.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        ref.read(chatProvider.notifier).clearHistory();
                      },
                      icon: const Icon(Icons.refresh_rounded,
                          color: AppColors.textMutedDark, size: 20),
                      tooltip: 'Clear chat',
                    ),
                ],
              ),
            ),

            // ── Messages ──
            Expanded(
              child: messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: messages.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length && isLoading) {
                          return _TypingIndicator(ctrl: _typingCtrl);
                        }
                        final msg = messages[index];
                        final isUser = msg.role == ChatRole.user;
                        final isSystem = msg.role == ChatRole.system;
                        if (isSystem) {
                          return _SystemMessage(text: msg.content);
                        }
                        return _MessageBubble(
                          message: msg,
                          isUser: isUser,
                          index: index,
                        );
                      },
                    ),
            ),

            // ── Input Area ──
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                border: Border(
                  top: BorderSide(
                      color: AppColors.glassBorder.withValues(alpha: 0.4)),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 120),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAltDark,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusXXL),
                            border: Border.all(
                              color: _hasText
                                  ? AppColors.primary.withValues(alpha: 0.5)
                                  : AppColors.borderDark,
                            ),
                          ),
                          child: TextField(
                            controller: _controller,
                            maxLines: null,
                            style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimaryDark),
                            decoration: InputDecoration(
                              hintText: 'Ask about travel...',
                              hintStyle: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.textMutedDark),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedScale(
                        scale: _hasText ? 1.0 : 0.85,
                        duration: const Duration(milliseconds: 150),
                        child: GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: _hasText
                                  ? AppColors.auroraGradient
                                  : const LinearGradient(colors: [
                                      AppColors.surfaceElevatedDark,
                                      AppColors.surfaceElevatedDark,
                                    ]),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusFull),
                              boxShadow: _hasText
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.35),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: const Icon(Icons.send_rounded,
                                color: Colors.white, size: 20),
                          ),
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
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Hero
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.auroraGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 38),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                duration: 2000.ms,
              ),
          const SizedBox(height: 20),
          Text(
            'Wander AI',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your personal AI travel concierge.\nAsk me anything about your next adventure!',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMutedDark,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'QUICK PROMPTS',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textMutedDark,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _quickPrompts.asMap().entries.map((e) {
              return GestureDetector(
                onTap: () => _sendMessage(e.value),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Text(
                    e.value,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ),
              )
                  .animate(delay: Duration(milliseconds: 200 + (e.key * 60)))
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1, end: 0);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;
  final int index;

  const _MessageBubble({
    required this.message,
    required this.isUser,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 8, bottom: 2),
                decoration: BoxDecoration(
                  gradient: AppColors.auroraGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 14),
              ),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.72,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isUser ? AppColors.auroraGradient : null,
                  color: isUser ? null : AppColors.surfaceElevatedDark,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppTheme.radiusXL),
                    topRight: const Radius.circular(AppTheme.radiusXL),
                    bottomLeft: Radius.circular(isUser ? AppTheme.radiusXL : 4),
                    bottomRight:
                        Radius.circular(isUser ? 4 : AppTheme.radiusXL),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isUser ? AppColors.primary : Colors.black)
                          .withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message.content,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isUser ? Colors.white : AppColors.textPrimaryDark,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            if (isUser) ...[
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(left: 8, bottom: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 16),
              ),
            ],
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index < 5 ? index * 50 : 0))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }
}

class _TypingIndicator extends StatelessWidget {
  final AnimationController ctrl;
  const _TypingIndicator({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: AppColors.auroraGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 14),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.surfaceElevatedDark,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusXL),
                  topRight: Radius.circular(AppTheme.radiusXL),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(AppTheme.radiusXL),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return AnimatedBuilder(
                    animation: ctrl,
                    builder: (_, __) {
                      final delay = i * 0.33;
                      final v = ((ctrl.value + delay) % 1.0);
                      final s = 0.6 + (v * 0.4);
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: s),
                          shape: BoxShape.circle,
                        ),
                        transform: Matrix4.diagonal3Values(s, s, 1.0),
                        transformAlignment: Alignment.center,
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

class _SystemMessage extends StatelessWidget {
  final String text;
  const _SystemMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.errorBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Text(
          text,
          style: AppTypography.labelSmall.copyWith(color: AppColors.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

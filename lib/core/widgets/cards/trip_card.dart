// ─── Trip Card ──────────────────────────────────────────────────────
// Premium trip summary card with image, dates, status, and progress.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';

enum TripCardStatus { draft, planned, active, completed, cancelled }

class TripCard extends StatelessWidget {
  final String destination;
  final String country;
  final String? imageUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? durationDays;
  final TripCardStatus status;
  final double? budgetUsedPercent;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TripCard({
    super.key,
    required this.destination,
    required this.country,
    this.imageUrl,
    this.startDate,
    this.endDate,
    this.durationDays,
    this.status = TripCardStatus.planned,
    this.budgetUsedPercent,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusConfig = _statusConfig;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            // ── Image ──
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppTheme.radiusXXL),
              ),
              child: SizedBox(
                width: 100,
                height: double.infinity,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.oceanGradient,
                          ),
                        ),
                        errorWidget: (_, __, ___) => _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
            ),
            // ── Info ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            destination,
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.textPrimaryDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(
                          label: statusConfig.label,
                          color: statusConfig.color,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.textMutedDark,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          country,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMutedDark,
                          ),
                        ),
                      ],
                    ),
                    if (startDate != null && endDate != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: AppColors.textMutedDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateRange(),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                          if (durationDays != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Text(
                                '$durationDays days',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    if (budgetUsedPercent != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Budget',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textMutedDark,
                                ),
                              ),
                              Text(
                                '${(budgetUsedPercent! * 100).toInt()}%',
                                style: AppTypography.labelSmall.copyWith(
                                  color: budgetUsedPercent! > 0.8
                                      ? AppColors.warning
                                      : AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                            child: LinearProgressIndicator(
                              value: budgetUsedPercent!.clamp(0.0, 1.0),
                              backgroundColor:
                                  AppColors.surfaceAltDark,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                budgetUsedPercent! > 0.8
                                    ? AppColors.warning
                                    : AppColors.success,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.4),
            AppColors.secondary.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.flight_takeoff, color: Colors.white54, size: 32),
      ),
    );
  }

  String _formatDateRange() {
    if (startDate == null || endDate == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${startDate!.day} ${months[startDate!.month - 1]} → '
        '${endDate!.day} ${months[endDate!.month - 1]}';
  }

  _TripStatusConfig get _statusConfig {
    switch (status) {
      case TripCardStatus.draft:
        return const _TripStatusConfig('Draft', AppColors.textMutedDark);
      case TripCardStatus.planned:
        return const _TripStatusConfig('Planned', AppColors.info);
      case TripCardStatus.active:
        return const _TripStatusConfig('Active', AppColors.success);
      case TripCardStatus.completed:
        return const _TripStatusConfig('Done', AppColors.secondary);
      case TripCardStatus.cancelled:
        return const _TripStatusConfig('Cancelled', AppColors.error);
    }
  }
}

class _TripStatusConfig {
  final String label;
  final Color color;
  const _TripStatusConfig(this.label, this.color);
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

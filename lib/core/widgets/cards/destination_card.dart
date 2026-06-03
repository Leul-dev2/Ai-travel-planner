// ─── Destination Card ────────────────────────────────────────────────
// Full-bleed image card with gradient overlay, rating, and save button.

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';

class DestinationCard extends StatefulWidget {
  final String name;
  final String country;
  final String imageUrl;
  final double? rating;
  final String? priceRange;
  final String? tag;
  final Color? tagColor;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final double height;
  final double? width;

  const DestinationCard({
    super.key,
    required this.name,
    required this.country,
    required this.imageUrl,
    this.rating,
    this.priceRange,
    this.tag,
    this.tagColor,
    this.isSaved = false,
    this.onTap,
    this.onSave,
    this.height = 200,
    this.width,
  });

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartCtrl;
  late Animation<double> _heartScale;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _heartScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_heartCtrl);
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _toggleSave() {
    setState(() => _isSaved = !_isSaved);
    _heartCtrl.forward(from: 0);
    widget.onSave?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
        child: SizedBox(
          height: widget.height,
          width: widget.width,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Background Image ──
              CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.surfaceAltDark,
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.textMutedDark,
                      size: 32,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.oceanGradient,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.landscape_outlined,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                ),
              ),

              // ── Gradient Overlay ──
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.darkOverlay,
                ),
              ),

              // ── Tag Badge ──
              if (widget.tag != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildTag(),
                ),

              // ── Save Button ──
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedBuilder(
                  animation: _heartScale,
                  builder: (_, __) => Transform.scale(
                    scale: _heartScale.value,
                    child: GestureDetector(
                      onTap: _toggleSave,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Icon(
                              _isSaved ? Icons.favorite : Icons.favorite_border,
                              color: _isSaved ? AppColors.accent : Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Bottom Info ──
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.name,
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              widget.country,
                              style: AppTypography.caption.copyWith(
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.rating != null) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.accentWarm,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              widget.rating!.toStringAsFixed(1),
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          if (widget.priceRange != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              widget.priceRange!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (widget.tagColor ?? AppColors.primary)
                .withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Text(
            widget.tag!.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

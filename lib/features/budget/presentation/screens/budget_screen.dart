// ─── Budget Screen ───────────────────────────────────────────────────
// Budget analytics dashboard with donut chart, category breakdown, timeline.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/animations/animated_counter.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAltDark,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: AppColors.textPrimaryDark, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Budget Analytics',
                        style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.textPrimaryDark)),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            // ── Total Budget Card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Budget',
                              style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white70)),
                          AnimatedCounter(
                            value: 2500,
                            prefix: '\$',
                            style: AppTypography.displaySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Bali Escape · 8 days',
                              style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white60)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Spent',
                              style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white54)),
                          AnimatedCounter(
                            value: 1075,
                            prefix: '\$',
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.accentWarm,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text('43% used',
                              style: AppTypography.caption.copyWith(
                                  color: AppColors.successLight)),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            ),

            // ── Donut Chart ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spending Breakdown',
                          style: AppTypography.titleSmall.copyWith(
                              color: AppColors.textPrimaryDark)),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 50,
                            sections: [
                              _buildSection(35, AppColors.categoryHotel, 'Hotel'),
                              _buildSection(25, AppColors.categoryFood, 'Food'),
                              _buildSection(20, AppColors.categoryTransport, 'Transport'),
                              _buildSection(15, AppColors.categoryActivity, 'Activities'),
                              _buildSection(5, AppColors.categoryOther, 'Other'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Legend
                      const Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _Legend(color: AppColors.categoryHotel, label: 'Hotel', value: '\$375'),
                          _Legend(color: AppColors.categoryFood, label: 'Food', value: '\$269'),
                          _Legend(color: AppColors.categoryTransport, label: 'Transport', value: '\$215'),
                          _Legend(color: AppColors.categoryActivity, label: 'Activities', value: '\$161'),
                          _Legend(color: AppColors.categoryOther, label: 'Other', value: '\$55'),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
            ),

            // ── Daily Spending ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Spending',
                          style: AppTypography.titleSmall.copyWith(
                              color: AppColors.textPrimaryDark)),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 160,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 250,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, _) => Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text('D${v.toInt() + 1}',
                                        style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.textMutedDark)),
                                  ),
                                ),
                              ),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              _buildBar(0, 180),
                              _buildBar(1, 120),
                              _buildBar(2, 200),
                              _buildBar(3, 95),
                              _buildBar(4, 160),
                              _buildBar(5, 130),
                              _buildBar(6, 220),
                              _buildBar(7, 70),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
            ),

            // ── Category Cards ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Categories',
                        style: AppTypography.titleSmall.copyWith(
                            color: AppColors.textPrimaryDark)),
                    const SizedBox(height: 14),
                    ...[
                      ('🏨', 'Hotel & Accommodation', '\$375', 0.35, AppColors.categoryHotel),
                      ('🍜', 'Food & Dining', '\$269', 0.25, AppColors.categoryFood),
                      ('🚕', 'Transport', '\$215', 0.20, AppColors.categoryTransport),
                      ('🎯', 'Activities', '\$161', 0.15, AppColors.categoryActivity),
                      ('📦', 'Other', '\$55', 0.05, AppColors.categoryOther),
                    ].asMap().entries.map((e) => _CategoryCard(
                          emoji: e.value.$1,
                          label: e.value.$2,
                          amount: e.value.$3,
                          percent: e.value.$4,
                          color: e.value.$5,
                          index: e.key,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildSection(double value, Color color, String title) {
    return PieChartSectionData(
      color: color,
      value: value,
      radius: 24,
      title: '',
    );
  }

  BarChartGroupData _buildBar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 250,
            color: AppColors.surfaceAltDark,
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _Legend({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text('$label ', style: AppTypography.caption.copyWith(
            color: AppColors.textSecondaryDark)),
        Text(value, style: AppTypography.caption.copyWith(
            color: AppColors.textPrimaryDark, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String amount;
  final double percent;
  final Color color;
  final int index;

  const _CategoryCard({
    required this.emoji,
    required this.label,
    required this.amount,
    required this.percent,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimaryDark)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: AppColors.surfaceAltDark,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimaryDark, fontWeight: FontWeight.w700)),
              Text('${(percent * 100).toInt()}%',
                  style: AppTypography.caption.copyWith(color: color)),
            ],
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 350 + (index * 60)))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }
}

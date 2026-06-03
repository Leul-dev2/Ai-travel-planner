// ─── App Dropdown ───────────────────────────────────────────────────
// Themed dropdown selector with label.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final bool enabled;

  const AppDropdown({
    super.key,
    required this.label,
    this.value,
    this.hint,
    required this.items,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceAltDark,
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          ),
          child: DropdownButton<T>(
            value: value,
            hint: hint != null
                ? Text(
                    hint!,
                    style: GoogleFonts.inter(
                      color: AppColors.textMutedDark,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  )
                : null,
            isExpanded: true,
            dropdownColor: AppColors.surfaceAltDark,
            underline: const SizedBox(),
            style: AppTypography.input.copyWith(
              color: AppColors.textPrimaryDark,
            ),
            items: items,
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }
}

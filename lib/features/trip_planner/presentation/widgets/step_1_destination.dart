import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/trip_provider.dart';

class Step1Destination extends ConsumerStatefulWidget {
  const Step1Destination({super.key});

  @override
  ConsumerState<Step1Destination> createState() => Step1DestinationState();
}

// Made public class to ensure global cross-file visibility for GlobalKey scoping
class Step1DestinationState extends ConsumerState<Step1Destination> {
  final _countryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  DateTime? _departureDate;
  DateTime? _returnDate;

  @override
  void initState() {
    super.initState();
    final formData = ref.read(tripFormProvider);
    _countryCtrl.text = formData.country;
    _cityCtrl.text = formData.city;
    _departureDate = formData.departureDate;
    _returnDate = formData.returnDate;

    _countryCtrl.addListener(() {
      ref.read(tripFormProvider.notifier).setCountry(_countryCtrl.text);
    });
    _cityCtrl.addListener(() {
      ref.read(tripFormProvider.notifier).setCity(_cityCtrl.text);
    });
  }

  @override
  void dispose() {
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  // Explicit sync hook targeted globally by the main wizard engine
  void commitToProvider() {
    final notifier = ref.read(tripFormProvider.notifier);
    notifier.setCountry(_countryCtrl.text);
    notifier.setCity(_cityCtrl.text);
    if (_departureDate != null && _returnDate != null) {
      notifier.setDates(_departureDate!, _returnDate!);
    }
  }

  Future<void> _selectDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _departureDate != null && _returnDate != null
          ? DateTimeRange(start: _departureDate!, end: _returnDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surfaceDark,
              onSurface: AppColors.textPrimaryDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _departureDate = picked.start;
        _returnDate = picked.end;
      });
      ref.read(tripFormProvider.notifier).setDates(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScreenHeader(
          line1: 'WHERE',
          line2: 'TO?',
          subtitle: 'Step 1: Destination and Dates',
        ),
        const SizedBox(height: 32),
        AppTextField(
          label: 'Country',
          hint: 'e.g., Japan',
          controller: _countryCtrl,
          prefixIcon: const Icon(Icons
              .public), // IconData wrapped within standard Icon widget elements
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'City',
          hint: 'e.g., Tokyo',
          controller: _cityCtrl,
          prefixIcon: const Icon(Icons
              .location_city), // IconData wrapped within standard Icon widget elements
        ),
        const SizedBox(height: 32),
        const SectionLabel('Travel Dates'),
        const SizedBox(height: 12),
        GlassCard(
          onTap: _selectDates,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: AppColors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _departureDate != null && _returnDate != null
                      ? '${_departureDate!.toLocal().toString().split(' ')[0]} - ${_returnDate!.toLocal().toString().split(' ')[0]}'
                      : 'Select Dates',
                  style: AppTypography.bodyMedium.copyWith(
                    color: _departureDate != null
                        ? AppColors.textPrimaryDark
                        : AppColors.textMutedDark,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMutedDark),
            ],
          ),
        ),
      ],
    );
  }
}

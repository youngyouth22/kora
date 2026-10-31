import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/app_text_field.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/features/routine/presentation/bloc/routine_bloc.dart';
import 'package:kora/features/routine/presentation/bloc/routine_event.dart';
import 'package:kora/features/routine/routine_injection.dart';

/// Full-screen daily skin check-in page (`public.checkins` in Supabase).
///
/// Captures `skin_feel` (1 = worse, 2 = same, 3 = better), `new_products`
/// boolean, and an optional `note`.
class RoutineCheckinPage extends StatefulWidget {
  /// Creates a [RoutineCheckinPage].
  const RoutineCheckinPage({super.key});

  @override
  State<RoutineCheckinPage> createState() => _RoutineCheckinPageState();
}

class _RoutineCheckinPageState extends State<RoutineCheckinPage> {
  int _selectedFeel = 3;
  bool _newProducts = false;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<RoutineBloc>()) {
      initRoutineInjection(getIt);
    }
    final existing = getIt<RoutineBloc>().state.todayCheckin;
    if (existing != null) {
      _selectedFeel = existing.skinFeel;
      _newProducts = existing.newProducts;
    }
    _noteController = TextEditingController(text: existing?.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onSave(BuildContext context) {
    context.read<RoutineBloc>().add(
      RoutineCheckinSubmitted(
        skinFeel: _selectedFeel,
        newProducts: _newProducts,
        note: _noteController.text.trim(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Daily skin check-in saved · Streak credited.',
          style: AppTypography.bodySMedium.copyWith(color: AppColors.grey50),
        ),
        backgroundColor: AppColors.primary700,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<RoutineBloc>()) {
      initRoutineInjection(getIt);
    }

    return BlocProvider<RoutineBloc>.value(
      value: getIt<RoutineBloc>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldColor,
            appBar: AppBar(
              backgroundColor: AppColors.scaffoldColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                'Daily Skin Check-in',
                style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
              ),
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                children: [
                  Text(
                    'How does your skin feel today?',
                    style: AppTypography.h5Bold.copyWith(
                      color: AppColors.grey1050,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your subjective comfort helps Kora detect early barrier '
                    'irritation alongside weekly scans.',
                    style: AppTypography.bodySRegular.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SkinFeelOptionCard(
                    value: 3,
                    selectedValue: _selectedFeel,
                    title: 'Hydrated & radiant',
                    subtitle: 'Comfortable barrier, zero tightness or stinging',
                    icon: Icons.sentiment_satisfied_alt_rounded,
                    onTap: () => setState(() => _selectedFeel = 3),
                  ),
                  const SizedBox(height: 10),
                  _SkinFeelOptionCard(
                    value: 2,
                    selectedValue: _selectedFeel,
                    title: 'Calm & steady',
                    subtitle: 'Same as usual, no noticeable changes today',
                    icon: Icons.sentiment_neutral_rounded,
                    onTap: () => setState(() => _selectedFeel = 2),
                  ),
                  const SizedBox(height: 10),
                  _SkinFeelOptionCard(
                    value: 1,
                    selectedValue: _selectedFeel,
                    title: 'More reactive / dry',
                    subtitle:
                        'Mild redness, flaking, or tightness after actives',
                    icon: Icons.sentiment_dissatisfied_rounded,
                    onTap: () => setState(() => _selectedFeel = 1),
                  ),
                  const SizedBox(height: 20),

                  KoraCard(
                    onTap: () => setState(() => _newProducts = !_newProducts),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    borderColor: _newProducts
                        ? AppColors.primary400
                        : AppColors.grey300,
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: _newProducts
                                ? AppColors.primary700
                                : Colors.transparent,
                            border: Border.all(
                              color: _newProducts
                                  ? AppColors.primary700
                                  : AppColors.grey400,
                              width: 1.5,
                            ),
                          ),
                          child: _newProducts
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: AppColors.grey50,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Did you try a new product today?',
                                style: AppTypography.bodyMSemiBold.copyWith(
                                  color: AppColors.grey1050,
                                ),
                              ),
                              Text(
                                'Flags potential confounders in your active '
                                'experiment.',
                                style: AppTypography.bodyXsRegular.copyWith(
                                  color: AppColors.grey700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Journal Note (Optional)',
                    style: AppTypography.bodyMSemiBold.copyWith(
                      color: AppColors.grey1050,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _noteController,
                    maxLines: 3,
                    hintText:
                        'e.g. Applied Retinol 0.3% over moisturizer buffer...',
                  ),
                  const SizedBox(height: 28),

                  PrimaryButton(
                    text: 'Save daily check-in',
                    height: 52,
                    backgroundColor: AppColors.primary700,
                    onPressed: () => _onSave(context),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SkinFeelOptionCard extends StatelessWidget {
  const _SkinFeelOptionCard({
    required this.value,
    required this.selectedValue,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final int value;
  final int selectedValue;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;
    return KoraCard(
      onTap: onTap,
      backgroundColor: isSelected ? AppColors.primary50 : AppColors.grey50,
      borderColor: isSelected ? AppColors.primary700 : AppColors.grey300,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary100 : AppColors.grey100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary300 : AppColors.grey300,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.primary800 : AppColors.grey700,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMSemiBold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isSelected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            color: isSelected ? AppColors.primary700 : AppColors.grey500,
            size: 20,
          ),
        ],
      ),
    );
  }
}

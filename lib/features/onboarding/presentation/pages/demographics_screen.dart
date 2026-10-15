// ignore_for_file: document_ignores

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/constants/mascot_pose.dart';
import 'package:kora/common/image_resources.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/constants/app_constants.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:kora/features/onboarding/presentation/widgets/onboarding_question_step.dart';
import 'package:kora/features/onboarding/presentation/widgets/onboarding_selection_tile.dart';

/// 3-step PageView collecting initial user profile demographics:
/// 1. Gender
/// 2. Age Range
/// 3. Sensitive Skin
class DemographicsScreen extends StatefulWidget {
  /// Creates a [DemographicsScreen].
  const DemographicsScreen({super.key});

  @override
  State<DemographicsScreen> createState() => _DemographicsScreenState();
}

class _DemographicsScreenState extends State<DemographicsScreen> {
  late final PageController _pageController;

  static const List<({String code, String name, String icon})> _genderOptions =
      [
        (
          code: 'female',
          name: 'Female',
          icon: ImageResources.famIconsFemale,
        ),
        (
          code: 'male',
          name: 'Male',
          icon: ImageResources.famIconsMale,
        ),
      ];

  static const List<({String code, String label})> _ageRangeOptions = [
    (code: 'under_25', label: 'Under 25'),
    (code: '25_34', label: '25–34'),
    (code: '35_44', label: '35–44'),
    (code: '45_54', label: '45–54'),
    (code: '55_plus', label: '55 or older'),
  ];

  @override
  void initState() {
    super.initState();
    final initialPage = context.read<OnboardingBloc>().state.demographicsStep;
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onStepBack(int currentStep) {
    if (currentStep > 0) {
      final prevStep = currentStep - 1;
      context.read<OnboardingBloc>().add(
        OnboardingDemographicsStepChanged(prevStep),
      );
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          prevStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    } else {
      context.pop();
    }
  }

  void _onStepNext(int currentStep) {
    if (currentStep < 2) {
      final nextStep = currentStep + 1;
      context.read<OnboardingBloc>().add(
        OnboardingDemographicsStepChanged(nextStep),
      );
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    } else {
      context.read<OnboardingBloc>().add(
        const OnboardingDemographicsSubmitted(),
      );
      unawaited(context.push(AppRoutes.onboardingDisclaimer));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listenWhen: (prev, current) =>
          prev.demographicsStep != current.demographicsStep,
      listener: (context, state) {
        if (_pageController.hasClients &&
            _pageController.page?.round() != state.demographicsStep) {
          _pageController.animateToPage(
            state.demographicsStep,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      },
      builder: (context, state) {
        final currentStep = state.demographicsStep;

        return Scaffold(
          backgroundColor: AppColors.scaffoldColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 72,
            leading: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                icon: SvgPicture.asset(
                  ImageResources.arrowBack,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppGreyColors.shade1050,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => _onStepBack(currentStep),
              ),
            ),
          ),
          body: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                _onStepBack(currentStep);
              }
            },
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    // 3-step PageView
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          // Step 1: Gender
                          _buildGenderStep(state),

                          // Step 2: Age Range
                          _buildAgeStep(state),

                          // Step 3: Sensitive Skin
                          _buildSensitiveSkinStep(state),
                        ],
                      ),
                    ),

                    // Bottom Action CTA
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16, top: 16),
                      child: PrimaryButton(
                        text: currentStep == 2 ? 'Continue' : 'Next',
                        onPressed: state.canProceedDemographicsStep
                            ? () => _onStepNext(currentStep)
                            : null,
                        isDisabled: !state.canProceedDemographicsStep,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenderStep(OnboardingState state) {
    return OnboardingQuestionStep(
      title: 'What is your gender identity?',
      subtitle:
          'This helps calibrate baseline skin hormone and texture markers.',
      mascotPose: MascotPose.wave,
      mascotHeroTag: state.demographicsStep == 0
          ? AppConstants.mascotHeroTag
          : null,
      child: Column(
        children: _genderOptions
            .map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OnboardingSelectionTile(
                  label: option.name,
                  isSelected:
                      state.demographics.gender == option.name ||
                      state.demographics.gender == option.code,
                  leading: SvgPicture.asset(
                    option.icon,
                    colorFilter: const ColorFilter.mode(
                      AppGreyColors.shade1050,
                      BlendMode.srcIn,
                    ),
                    width: 24,
                  ),
                  onTap: () {
                    context.read<OnboardingBloc>().add(
                      OnboardingGenderSelected(option.name),
                    );
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAgeStep(OnboardingState state) {
    return OnboardingQuestionStep(
      title: 'What is your age range?',
      subtitle:
          'Skin cellular turnover and elasticity naturally evolve with age.',
      mascotPose: MascotPose.wave,
      child: Column(
        children: _ageRangeOptions
            .map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OnboardingSelectionTile(
                  label: option.label,
                  isSelected:
                      state.demographics.ageRange == option.label ||
                      state.demographics.ageRange == option.code,
                  onTap: () {
                    context.read<OnboardingBloc>().add(
                      OnboardingAgeRangeSelected(option.label),
                    );
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSensitiveSkinStep(OnboardingState state) {
    final sensitiveValue = state.demographics.hasSensitiveSkin;

    return OnboardingQuestionStep(
      title: 'Do you have sensitive skin?',
      subtitle:
          'Helps tailor tracking tolerance when testing active ingredients.',
      mascotPose: MascotPose.wave,
      child: Column(
        children: [
          OnboardingSelectionTile(
            label: 'Yes, easily sensitized',
            subtitle: 'Prone to redness, stinging, or reactions',
            isSelected: sensitiveValue ?? false,
            leading: Image.asset(
              ImageResources.sensitiveSkinIcon,
              height: 40,
              fit: BoxFit.cover,
            ),
            onTap: () {
              context.read<OnboardingBloc>().add(
                const OnboardingSensitiveSkinSelected(true),
              );
            },
          ),
          const SizedBox(height: 12),
          OnboardingSelectionTile(
            label: 'No, generally resilient',
            subtitle: 'Rarely reacts to cosmetic ingredients',
            isSelected: sensitiveValue != null && !sensitiveValue,
            leading: Image.asset(
              ImageResources.nonSensitiveSkinIcon,
              height: 40,
              fit: BoxFit.cover,
            ),
            onTap: () {
              context.read<OnboardingBloc>().add(
                const OnboardingSensitiveSkinSelected(false),
              );
            },
          ),
        ],
      ),
    );
  }
}

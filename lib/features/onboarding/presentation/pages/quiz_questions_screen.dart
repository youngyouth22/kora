// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/constants/mascot_pose.dart';
import 'package:kora/common/image_resources.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/constants/app_constants.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:kora/features/onboarding/presentation/widgets/onboarding_progress_bar.dart';
import 'package:kora/features/onboarding/presentation/widgets/onboarding_question_step.dart';
import 'package:kora/features/onboarding/presentation/widgets/onboarding_selection_tile.dart';

/// 6-step questionnaire screen collecting user skin profile and preferences.
///
/// Steps:
/// 1. Skin tone selection (Fitzpatrick swatch markers)
/// 2. Describe skin type (single-select)
/// 3. Primary skin goals & concerns (multi-select with icons)
/// 4. Current skincare routine (single-select with badge indicators)
/// 5. Testing new products & experiments (single-select with badge indicators)
/// 6. Tailored assisted skincare preference (single-select with recommendation tiers)
class QuizQuestionsScreen extends StatefulWidget {
  /// Creates a [QuizQuestionsScreen].
  const QuizQuestionsScreen({
    this.sessionState,
    super.key,
  });

  /// Injected session state to notify GoRouter when onboarding completes.
  final AppSessionState? sessionState;

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  late final PageController _pageController;

  static const int _totalSteps = 6;

  static const List<({String name, String subtitle, Color color})>
  _skinToneOptions = [
    (
      name: 'Very Fair',
      subtitle: 'Always burns easily, never tans',
      color: AppSkinToneColors.typeI,
    ),
    (
      name: 'Fair',
      subtitle: 'Burns easily, tans minimally',
      color: AppSkinToneColors.typeII,
    ),
    (
      name: 'Medium',
      subtitle: 'Burns moderately, tans gradually',
      color: AppSkinToneColors.typeIII,
    ),
    (
      name: 'Olive',
      subtitle: 'Burns minimally, tans easily',
      color: AppSkinToneColors.typeIV,
    ),
    (
      name: 'Brown',
      subtitle: 'Rarely burns, tans profusely',
      color: AppSkinToneColors.typeV,
    ),
    (
      name: 'Dark Brown',
      subtitle: 'Almost never burns, deeply pigmented',
      color: AppSkinToneColors.typeVI,
    ),
  ];

  static const List<({String name, String subtitle})> _describeSkinOptions = [
    (name: 'Oily', subtitle: 'Shiny throughout your face'),
    (name: 'Dry', subtitle: 'Tight, flaky, or lacks moisture'),
    (name: 'Combination', subtitle: 'Oily T-zone, normal to dry cheeks'),
    (name: 'Normal', subtitle: 'Balanced, rarely tight or shiny'),
    (
      name: "I'm not sure",
      subtitle: 'We will calibrate your baseline from your scans',
    ),
  ];

  static const List<({String name, IconData icon})> _skinGoalsOptions = [
    (name: 'Acne & blemishes', icon: Icons.flare_outlined),
    (name: 'Dark spots & pigmentation', icon: Icons.lens_blur_outlined),
    (name: 'Redness & sensitivity', icon: Icons.spa_outlined),
    (name: 'Pores & blackheads', icon: Icons.grain_rounded),
    (name: 'Fine lines & wrinkles', icon: Icons.waves_rounded),
    (name: "Crow's feet & eye area", icon: Icons.remove_red_eye_outlined),
    (name: 'Dehydration & dullness', icon: Icons.water_drop_outlined),
    (name: 'Uneven skin texture', icon: Icons.hub_outlined),
  ];

  static const List<
    ({
      String label,
      String subtitle,
      Color badgeBg,
      Color badgeIcon,
      IconData icon,
    })
  >
  _currentRoutineOptions = [
    (
      label: 'Minimalist (1–2 products)',
      subtitle: 'Basic cleanser, moisturizer, or sunscreen',
      badgeBg: AppBadgeColors.savingsBg,
      badgeIcon: AppBadgeColors.savingsIcon,
      icon: Icons.clean_hands_outlined,
    ),
    (
      label: 'Moderate (3–4 products)',
      subtitle: 'Cleanser, toner, serum, and moisturizer',
      badgeBg: AppBadgeColors.valueBg,
      badgeIcon: AppBadgeColors.valueIcon,
      icon: Icons.spa_outlined,
    ),
    (
      label: 'Advanced (5+ products)',
      subtitle: 'Layered regimen with targeted actives and treatments',
      badgeBg: AppBadgeColors.innovativeBg,
      badgeIcon: AppBadgeColors.innovativeIcon,
      icon: Icons.layers_outlined,
    ),
    (
      label: 'Irregular or none',
      subtitle: 'Starting fresh with Kora to build consistency',
      badgeBg: AppBadgeColors.ultimateBg,
      badgeIcon: AppBadgeColors.ultimateIcon,
      icon: Icons.refresh_rounded,
    ),
  ];

  static const List<
    ({
      String label,
      String subtitle,
      Color badgeBg,
      Color badgeIcon,
      IconData icon,
    })
  >
  _testingProductOptions = [
    (
      label: 'Yes, started in the last 2 weeks',
      subtitle: 'Track its impact from baseline to verify if it works',
      badgeBg: AppBadgeColors.valueBg,
      badgeIcon: AppBadgeColors.valueIcon,
      icon: Icons.science_outlined,
    ),
    (
      label: 'Planning to introduce one soon',
      subtitle: 'Set up an experiment before adding it to your routine',
      badgeBg: AppBadgeColors.innovativeBg,
      badgeIcon: AppBadgeColors.innovativeIcon,
      icon: Icons.add_circle_outline_rounded,
    ),
    (
      label: 'No, testing routine stability',
      subtitle: 'Confirm my current routine keeps my skin healthy and stable',
      badgeBg: AppBadgeColors.savingsBg,
      badgeIcon: AppBadgeColors.savingsIcon,
      icon: Icons.balance_rounded,
    ),
  ];

  static const List<
    ({
      String label,
      String subtitle,
      Color badgeBg,
      Color badgeIcon,
      IconData icon,
    })
  >
  _tailoredSkincareOptions = [
    (
      label: 'Yes, propose tailored boosters',
      subtitle:
          'Receive proactive ingredient suggestions backed by your scan data',
      badgeBg: AppBadgeColors.valueBg,
      badgeIcon: AppBadgeColors.valueIcon,
      icon: Icons.auto_awesome_rounded,
    ),
    (
      label: 'Only when skin metrics decline',
      subtitle:
          'Alert me only when irritation, redness, or barrier issues arise',
      badgeBg: AppBadgeColors.savingsBg,
      badgeIcon: AppBadgeColors.savingsIcon,
      icon: Icons.notifications_active_outlined,
    ),
    (
      label: 'No, track my current routine only',
      subtitle: 'Keep tracking focused strictly on my existing products',
      badgeBg: AppBadgeColors.innovativeBg,
      badgeIcon: AppBadgeColors.innovativeIcon,
      icon: Icons.check_circle_outline_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final initialPage = context.read<OnboardingBloc>().state.quizStep;
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
      context.read<OnboardingBloc>().add(OnboardingQuizStepChanged(prevStep));
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
    if (currentStep < _totalSteps - 1) {
      final nextStep = currentStep + 1;
      context.read<OnboardingBloc>().add(OnboardingQuizStepChanged(nextStep));
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    } else {
      context.read<OnboardingBloc>().add(const OnboardingQuizSubmitted());
    }
  }

  void _onSelectSingleAnswer({
    required int questionIndex,
    required String option,
  }) {
    context.read<OnboardingBloc>().add(
      OnboardingQuestionAnswered(
        questionIndex: questionIndex,
        answer: option,
      ),
    );
  }

  void _onToggleMultipleAnswer({
    required int questionIndex,
    required String option,
    required Map<int, String> currentAnswers,
    bool isExclusive = false,
  }) {
    final raw = currentAnswers[questionIndex] ?? '';
    final selectedList = raw.isEmpty
        ? <String>[]
        : raw
              .split(', ')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

    List<String> nextList;
    if (isExclusive) {
      if (selectedList.contains(option)) {
        nextList = [];
      } else {
        nextList = [option];
      }
    } else {
      nextList = List<String>.from(selectedList)..remove('None');
      if (nextList.contains(option)) {
        nextList.remove(option);
      } else {
        nextList.add(option);
      }
    }

    context.read<OnboardingBloc>().add(
      OnboardingQuestionAnswered(
        questionIndex: questionIndex,
        answer: nextList.join(', '),
      ),
    );
  }

  bool _isOptionSelected({
    required int questionIndex,
    required String option,
    required Map<int, String> currentAnswers,
    required bool isMultiple,
  }) {
    final raw = currentAnswers[questionIndex];
    if (raw == null || raw.isEmpty) return false;
    if (isMultiple) {
      final list = raw.split(', ').map((e) => e.trim());
      return list.contains(option);
    }
    return raw == option;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listenWhen: (prev, current) =>
          prev.quizStep != current.quizStep ||
          prev.isOnboardingCompleted != current.isOnboardingCompleted,
      listener: (context, state) {
        if (state.isOnboardingCompleted) {
          final session =
              widget.sessionState ??
              (GetIt.instance.isRegistered<AppSessionState>()
                  ? GetIt.instance<AppSessionState>()
                  : null);
          session?.setIntendedDestination(AppRoutes.scanCapture);
          session?.setOnboardingCompleted(completed: true);
          if (GoRouter.maybeOf(context) != null) {
            context.go(AppRoutes.scanCapture);
          }
          return;
        }

        if (_pageController.hasClients &&
            _pageController.page?.round() != state.quizStep) {
          _pageController.animateToPage(
            state.quizStep,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      },
      builder: (context, state) {
        final currentStep = state.quizStep;
        final hasSelectedCurrentAnswer = state.canProceedQuizStep;
        final isLastStep = currentStep == _totalSteps - 1;

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
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(right: 24),
              child: OnboardingProgressBar(
                currentStep: currentStep + 1,
                totalSteps: _totalSteps,
                title: 'Personalizing Your Plan',
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
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildSkinToneStep(state),
                          _buildDescribeSkinStep(state),
                          _buildSkinGoalsStep(state),
                          _buildCurrentRoutineStep(state),
                          _buildTestingProductStep(state),
                          _buildTailoredSkincareStep(state),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16, top: 16),
                      child: PrimaryButton(
                        text: isLastStep ? 'Complete & Start' : 'Next',
                        onPressed: hasSelectedCurrentAnswer
                            ? () => _onStepNext(currentStep)
                            : null,
                        isDisabled: !hasSelectedCurrentAnswer,
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

  Widget _buildSkinToneStep(OnboardingState state) {
    return OnboardingQuestionStep(
      title: 'What is your skin tone?',
      subtitle:
          'Choose the tone that best matches your natural skin complexion.',
      mascotPose: MascotPose.wave,
      mascotHeroTag: state.quizStep == 0 ? AppConstants.mascotHeroTag : null,
      child: Column(
        children: _skinToneOptions
            .map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OnboardingSelectionTile(
                  label: option.name,
                  subtitle: option.subtitle,
                  isSelected: _isOptionSelected(
                    questionIndex: 0,
                    option: option.name,
                    currentAnswers: state.quizAnswers,
                    isMultiple: false,
                  ),
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: option.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppGreyColors.shade400,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onTap: () => _onSelectSingleAnswer(
                    questionIndex: 0,
                    option: option.name,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDescribeSkinStep(OnboardingState state) {
    return OnboardingQuestionStep(
      title: 'How would you describe your skin?',
      subtitle: 'Based on how your skin feels a few hours after cleansing.',
      mascotPose: MascotPose.wave,
      child: Column(
        children: _describeSkinOptions
            .map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OnboardingSelectionTile(
                  label: option.name,
                  subtitle: option.subtitle,
                  isSelected: _isOptionSelected(
                    questionIndex: 1,
                    option: option.name,
                    currentAnswers: state.quizAnswers,
                    isMultiple: false,
                  ),
                  onTap: () => _onSelectSingleAnswer(
                    questionIndex: 1,
                    option: option.name,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSkinGoalsStep(OnboardingState state) {
    return OnboardingQuestionStep(
      title: 'What are your primary skin goals?',
      subtitle: 'Select all concerns you want Kora to monitor and track on your scans.',
      mascotPose: MascotPose.writing,
      child: Column(
        children: _skinGoalsOptions
            .map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OnboardingSelectionTile(
                  label: option.name,
                  showCheckmark: true,
                  isSelected: _isOptionSelected(
                    questionIndex: 2,
                    option: option.name,
                    currentAnswers: state.quizAnswers,
                    isMultiple: true,
                  ),
                  leading: Icon(
                    option.icon,
                    color: AppGreyColors.shade1050,
                    size: 24,
                  ),
                  onTap: () => _onToggleMultipleAnswer(
                    questionIndex: 2,
                    option: option.name,
                    currentAnswers: state.quizAnswers,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCurrentRoutineStep(OnboardingState state) {
    return OnboardingQuestionStep(
      title: 'What does your current skincare routine look like?',
      subtitle: 'This helps Kora baseline your product regimen and detect what actually works.',
      mascotPose: MascotPose.wave,
      child: Column(
        children: _currentRoutineOptions
            .map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OnboardingSelectionTile(
                  label: option.label,
                  subtitle: option.subtitle,
                  isSelected: _isOptionSelected(
                    questionIndex: 3,
                    option: option.label,
                    currentAnswers: state.quizAnswers,
                    isMultiple: false,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: option.badgeBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      option.icon,
                      color: option.badgeIcon,
                      size: 22,
                    ),
                  ),
                  onTap: () => _onSelectSingleAnswer(
                    questionIndex: 3,
                    option: option.label,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTestingProductStep(OnboardingState state) {
    return OnboardingQuestionStep(
      title: 'Are you currently testing or introducing a new product?',
      subtitle: 'Kora can run a structured experiment to prove if it really improves your skin.',
      mascotPose: MascotPose.writing,
      child: Column(
        children: _testingProductOptions
            .map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OnboardingSelectionTile(
                  label: option.label,
                  subtitle: option.subtitle,
                  isSelected: _isOptionSelected(
                    questionIndex: 4,
                    option: option.label,
                    currentAnswers: state.quizAnswers,
                    isMultiple: false,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: option.badgeBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      option.icon,
                      color: option.badgeIcon,
                      size: 22,
                    ),
                  ),
                  onTap: () => _onSelectSingleAnswer(
                    questionIndex: 4,
                    option: option.label,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTailoredSkincareStep(OnboardingState state) {
    return OnboardingQuestionStep(
      title: 'How should Kora assist you?',
      subtitle: 'We adapt recommendations and alerts based on your weekly skin metrics.',
      mascotPose: MascotPose.success,
      child: Column(
        children: _tailoredSkincareOptions
            .map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OnboardingSelectionTile(
                  label: option.label,
                  subtitle: option.subtitle,
                  isSelected: _isOptionSelected(
                    questionIndex: 5,
                    option: option.label,
                    currentAnswers: state.quizAnswers,
                    isMultiple: false,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: option.badgeBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      option.icon,
                      color: option.badgeIcon,
                      size: 22,
                    ),
                  ),
                  onTap: () => _onSelectSingleAnswer(
                    questionIndex: 5,
                    option: option.label,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

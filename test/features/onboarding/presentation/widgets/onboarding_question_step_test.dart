import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/constants/mascot_pose.dart';
import 'package:kora/common/widgets/mascot_illustration.dart';
import 'package:kora/features/onboarding/presentation/widgets/onboarding_question_step.dart';

final Uint8List _transparentPng = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    return ByteData.sublistView(_transparentPng);
  }

  @override
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async {
    final data = const StandardMessageCodec().encodeMessage(
      <String, dynamic>{
        MascotPose.wave.path: <dynamic>[],
        MascotPose.writing.path: <dynamic>[],
        MascotPose.success.path: <dynamic>[],
      },
    )!;
    return parser(data);
  }
}

void main() {
  group('OnboardingQuestionStep Widget Tests', () {
    Widget buildTestWidget({
      required String title,
      required Widget child,
      String? subtitle,
      MascotPose? mascotPose,
      Widget? mascot,
      String? mascotHeroTag,
      double mascotSize = 96.0,
      bool isScrollable = true,
      EdgeInsetsGeometry padding = EdgeInsets.zero,
    }) {
      return MaterialApp(
        home: DefaultAssetBundle(
          bundle: _FakeAssetBundle(),
          child: Scaffold(
            body: OnboardingQuestionStep(
              title: title,
              subtitle: subtitle,
              mascotPose: mascotPose,
              mascot: mascot,
              mascotHeroTag: mascotHeroTag,
              mascotSize: mascotSize,
              isScrollable: isScrollable,
              padding: padding,
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('renders title and child with default styling', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          title: 'Primary Skincare Goal',
          child: const Text('Options List'),
        ),
      );

      final titleFinder = find.text('Primary Skincare Goal');
      expect(titleFinder, findsOneWidget);

      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style?.fontSize, AppTypography.h4Medium.fontSize);
      expect(titleWidget.style?.fontWeight, AppTypography.h4Medium.fontWeight);
      expect(titleWidget.style?.color, AppGreyColors.shade1050);

      expect(find.text('Options List'), findsOneWidget);
      expect(find.byType(MascotIllustration), findsNothing);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          title: 'Primary Skincare Goal',
          subtitle: 'Select the main focus for tracking.',
          child: const Text('Options List'),
        ),
      );

      final subtitleFinder = find.text('Select the main focus for tracking.');
      expect(subtitleFinder, findsOneWidget);

      final subtitleWidget = tester.widget<Text>(subtitleFinder);
      expect(
        subtitleWidget.style?.fontSize,
        AppTypography.bodyMRegular.fontSize,
      );
      expect(subtitleWidget.style?.color, AppGreyColors.shade950);
    });

    testWidgets('renders mascot illustration when mascotPose is passed', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          title: 'Question with Mascot',
          mascotPose: MascotPose.wave,
          child: const Text('Options List'),
        ),
      );

      final mascotFinder = find.byType(MascotIllustration);
      expect(mascotFinder, findsOneWidget);

      final illustration = tester.widget<MascotIllustration>(mascotFinder);
      expect(illustration.pose, MascotPose.wave);
      expect(illustration.size, 96.0);
    });

    testWidgets('renders custom mascot widget when mascot is passed', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          title: 'Custom Mascot Question',
          mascot: const KeyedSubtree(
            key: Key('custom_mascot'),
            child: Text('Custom Mascot Widget'),
          ),
          child: const Text('Options List'),
        ),
      );

      expect(find.byKey(const Key('custom_mascot')), findsOneWidget);
      expect(find.byType(MascotIllustration), findsNothing);
    });

    testWidgets('supports non-scrollable configuration', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          title: 'Non-scrollable Step',
          isScrollable: false,
          child: const Text('Options List'),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.text('Non-scrollable Step'), findsOneWidget);
      expect(find.text('Options List'), findsOneWidget);
    });

    testWidgets('renders Hero wrapper when mascotHeroTag is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          title: 'Question with Hero Mascot',
          mascotPose: MascotPose.wave,
          mascotHeroTag: 'test_mascot_hero',
          child: const Text('Options List'),
        ),
      );

      final heroFinder = find.byType(Hero);
      expect(heroFinder, findsOneWidget);

      final heroWidget = tester.widget<Hero>(heroFinder);
      expect(heroWidget.tag, 'test_mascot_hero');
      expect(heroWidget.flightShuttleBuilder, isNotNull);
    });
  });
}

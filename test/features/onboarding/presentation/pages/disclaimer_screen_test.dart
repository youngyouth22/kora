import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/constants/mascot_pose.dart';
import 'package:kora/common/widgets/mascot_illustration.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/constants/app_constants.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/onboarding/presentation/pages/disclaimer_screen.dart';

void main() {
  group('DisclaimerScreen Widget Tests', () {
    testWidgets(
      'renders mascot illustration with success pose and Hero widget',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: DisclaimerScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify mascot illustration presence and pose
        final mascotFinder = find.byType(MascotIllustration);
        expect(mascotFinder, findsOneWidget);

        final mascotWidget = tester.widget<MascotIllustration>(mascotFinder);
        expect(mascotWidget.pose, MascotPose.success);
        expect(mascotWidget.size, 200);

        // Verify Hero configuration
        final heroFinder = find.byType(Hero);
        expect(heroFinder, findsOneWidget);

        final heroWidget = tester.widget<Hero>(heroFinder);
        expect(heroWidget.tag, AppConstants.mascotHeroTag);
        expect(heroWidget.flightShuttleBuilder, isNotNull);

        // Verify blurred background container
        final filteredFinder = find.byType(ImageFiltered);
        expect(filteredFinder, findsOneWidget);

        final blurContainerFinder = find.descendant(
          of: filteredFinder,
          matching: find.byType(Container),
        );
        expect(blurContainerFinder, findsOneWidget);

        final blurContainer = tester.widget<Container>(blurContainerFinder);
        final decoration = blurContainer.decoration as BoxDecoration?;
        expect(decoration, isNotNull);
        expect(decoration!.color, AppColors.primary500);

        // Verify title and subtitle text
        expect(
          find.textContaining('Great Start'),
          findsOneWidget,
        );
        expect(
          find.textContaining('replace your dermatologist'),
          findsOneWidget,
        );

        // Verify PrimaryButton CTA
        final buttonFinder = find.byType(PrimaryButton);
        expect(buttonFinder, findsOneWidget);
        expect(find.text("Let's start!"), findsOneWidget);
      },
    );

    testWidgets("tapping Let's start! CTA navigates to quiz questions screen", (
      tester,
    ) async {
      var navigatedToQuestions = false;

      final router = GoRouter(
        initialLocation: '/disclaimer',
        routes: [
          GoRoute(
            path: '/disclaimer',
            builder: (context, state) => const DisclaimerScreen(),
          ),
          GoRoute(
            path: AppRoutes.onboardingQuestions,
            builder: (context, state) {
              navigatedToQuestions = true;
              return const Scaffold(body: Text('Quiz Questions Screen'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      final buttonFinder = find.widgetWithText(PrimaryButton, "Let's start!");
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(navigatedToQuestions, isTrue);
      expect(find.text('Quiz Questions Screen'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/constants/mascot_pose.dart';
import 'package:kora/common/widgets/mascot_illustration.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/onboarding/presentation/pages/mascot_screen.dart';

void main() {
  group('MascotScreen Widget Tests', () {
    testWidgets('renders mascot illustration, blurred background, and text', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MascotScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify mascot illustration presence and pose
      final mascotFinder = find.byType(MascotIllustration);
      expect(mascotFinder, findsOneWidget);

      final mascotWidget = tester.widget<MascotIllustration>(mascotFinder);
      expect(mascotWidget.pose, MascotPose.wave);
      expect(mascotWidget.size, 200);

      // Verify blurred background circle / oval
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

      final constraints = blurContainer.constraints;
      expect(constraints?.minWidth, 126);
      expect(constraints?.maxWidth, 126);
      expect(constraints?.minHeight, 180);
      expect(constraints?.maxHeight, 180);

      // Verify header text
      expect(
        find.textContaining("Hi, I'm Kora!"),
        findsOneWidget,
      );
      expect(
        find.textContaining('boost your skincare results'),
        findsOneWidget,
      );

      // Verify PrimaryButton CTA
      final buttonFinder = find.byType(PrimaryButton);
      expect(buttonFinder, findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('tapping Next CTA navigates to demographics screen', (
      tester,
    ) async {
      var navigatedToDemographics = false;

      final router = GoRouter(
        initialLocation: '/mascot',
        routes: [
          GoRoute(
            path: '/mascot',
            builder: (context, state) => const MascotScreen(),
          ),
          GoRoute(
            path: AppRoutes.onboardingDemographics,
            builder: (context, state) {
              navigatedToDemographics = true;
              return const Scaffold(body: Text('Demographics Screen'));
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

      final buttonFinder = find.widgetWithText(PrimaryButton, 'Next');
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(navigatedToDemographics, isTrue);
      expect(find.text('Demographics Screen'), findsOneWidget);
    });
  });
}

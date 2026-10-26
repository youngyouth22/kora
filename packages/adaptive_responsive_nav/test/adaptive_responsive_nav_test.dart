import 'package:adaptive_responsive_nav/adaptive_responsive_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bar Animations', () {
    test('creates all animation curves without error', () {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );

      final barAnim = BarAnimation(parent: controller);
      final offsetAnim = OffsetAnimation(parent: controller);
      final railAnim = RailAnimation(parent: controller);
      final sizeAnim = SizeAnimation(parent: controller);

      expect(barAnim.value, 1.0);
      expect(railAnim.value, 0.0);
      expect(offsetAnim.value, 0.0);
      expect(sizeAnim.value, 0.0);

      controller.dispose();
    });
  });

  group('AdaptiveNavIcon', () {
    testWidgets('renders IconData correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveNavIcon(
              icon: Icons.home,
              color: Colors.blue,
              size: 24,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('renders custom Widget correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveNavIcon(
              icon: Text('Custom'),
            ),
          ),
        ),
      );

      expect(find.text('Custom'), findsOneWidget);
    });
  });

  group('AdaptiveResponsiveScaffold', () {
    const destinations = [
      AdaptiveNavDestination(
        index: 0,
        title: 'Home',
        icon: Icons.home,
      ),
      AdaptiveNavDestination(
        index: 1,
        title: 'Settings',
        icon: Icons.settings,
      ),
    ];

    testWidgets('renders bottom bar on mobile screen width', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      int selected = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveResponsiveScaffold(
            destinations: destinations,
            selectedIndex: selected,
            onDestinationSelected: (index) => selected = index,
            body: const Text('Mobile Content'),
          ),
        ),
      );

      expect(find.text('Mobile Content'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);

      await tester.tap(find.text('Settings'));
      await tester.pump();
      expect(selected, 1);
    });

    testWidgets('renders navigation rail on large desktop screen width',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      int selected = 0;
      bool settingsPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveResponsiveScaffold(
            destinations: destinations,
            selectedIndex: selected,
            onDestinationSelected: (index) => selected = index,
            onSettingsPressed: () => settingsPressed = true,
            body: const Text('Desktop Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Desktop Content'), findsOneWidget);
      expect(find.byType(NavigationRail), findsOneWidget);

      final settingsBtn =
          find.byKey(const Key('nav_rail_settings_extended_button'));
      expect(settingsBtn, findsOneWidget);
      await tester.tap(settingsBtn);
      await tester.pump();
      expect(settingsPressed, isTrue);
    });

    testWidgets('respects onDestinationTap interception', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      int selected = 0;
      int intercepted = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveResponsiveScaffold(
            destinations: destinations,
            selectedIndex: selected,
            onDestinationTap: (index) {
              intercepted = index;
              return false; // Intercept & block
            },
            onDestinationSelected: (index) => selected = index,
            body: const Text('Mobile Content'),
          ),
        ),
      );

      await tester.tap(find.text('Settings'));
      await tester.pump();

      expect(intercepted, 1);
      expect(selected, 0); // Not changed
    });
  });
}

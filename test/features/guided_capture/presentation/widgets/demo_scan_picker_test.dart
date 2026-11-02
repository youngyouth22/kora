import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/guided_capture/presentation/widgets/demo_scan_picker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock rootBundle image binary loading for tests
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        // Return 16 dummy bytes representing a dummy image
        final bytes = Uint8List(16);
        return ByteData.view(bytes.buffer);
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  group('DemoScanPicker', () {
    testWidgets('renders initial trigger button with Week 1 preset', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DemoScanPicker(
              onCaptureDemoPhoto: (_) async {},
            ),
          ),
        ),
      );

      expect(find.text('DÉMO'), findsOneWidget);
      expect(find.text('S1'), findsOneWidget);
      expect(find.text('Toucher pour changer'), findsOneWidget);
    });

    testWidgets('expands and displays all 3 weekly presets when tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DemoScanPicker(
              onCaptureDemoPhoto: (_) async {},
            ),
          ),
        ),
      );

      // Tap trigger button to expand options
      await tester.tap(find.text('DÉMO'));
      await tester.pumpAndSettle();

      expect(find.text('Visage Démo (Vidéo)'), findsOneWidget);
      expect(find.text('Semaine 1'), findsOneWidget);
      expect(find.text('Semaine 3'), findsOneWidget);
      expect(find.text('Semaine 6'), findsOneWidget);
      expect(find.text('Point de départ'), findsOneWidget);
      expect(find.text('Mi-parcours'), findsOneWidget);
      expect(find.text('Bilan final'), findsOneWidget);
    });

    testWidgets('executes onCaptureDemoPhoto when preset option is tapped', (
      tester,
    ) async {
      XFile? capturedFile;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DemoScanPicker(
              onCaptureDemoPhoto: (photo) async {
                capturedFile = photo;
              },
            ),
          ),
        ),
      );

      // Expand sheet
      await tester.tap(find.text('DÉMO'));
      await tester.pumpAndSettle();

      // Tap Semaine 1
      await tester.tap(find.text('Semaine 1'));
      await tester.pumpAndSettle();

      expect(capturedFile, isNotNull);
      expect(capturedFile!.path.contains('demo_week1'), isTrue);
    });

    testWidgets('can select and capture Semaine 3 and Semaine 6', (
      tester,
    ) async {
      XFile? capturedFile;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DemoScanPicker(
              onCaptureDemoPhoto: (photo) async {
                capturedFile = photo;
              },
            ),
          ),
        ),
      );

      // Expand sheet
      await tester.tap(find.text('DÉMO'));
      await tester.pumpAndSettle();

      // Tap Semaine 3
      await tester.tap(find.text('Semaine 3'));
      await tester.pumpAndSettle();

      expect(capturedFile, isNotNull);
      expect(capturedFile!.path.contains('demo_week3'), isTrue);
    });
  });
}

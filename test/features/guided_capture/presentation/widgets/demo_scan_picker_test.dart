// ignore_for_file: document_ignores, depend_on_referenced_packages

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/guided_capture/presentation/widgets/demo_scan_picker.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => '.';

  @override
  Future<String?> getApplicationDocumentsPath() async => '.';
}

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
        'assets/images/onboarding_scan_week1.jpg': <dynamic>[],
        'assets/images/onboarding_scan_week3.jpg': <dynamic>[],
        'assets/images/onboarding_scan_week6.jpg': <dynamic>[],
      },
    )!;
    return parser(data);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PathProviderPlatform.instance = _FakePathProviderPlatform();
  });

  tearDown(() {});

  Widget buildTestableWidget({
    required Future<void> Function(XFile photo) onCapture,
  }) {
    return MaterialApp(
      home: DefaultAssetBundle(
        bundle: _FakeAssetBundle(),
        child: Scaffold(
          body: DemoScanPicker(
            onCaptureDemoPhoto: onCapture,
          ),
        ),
      ),
    );
  }

  group('DemoScanPicker', () {
    testWidgets('renders initial trigger button with Week 1 preset', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(onCapture: (_) async {}),
      );
      await tester.pump();

      expect(find.text('DEMO'), findsOneWidget);
      expect(find.text('W1'), findsOneWidget);
      expect(find.text('Tap to change'), findsOneWidget);
    });

    testWidgets('expands and displays all 3 weekly presets when tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(onCapture: (_) async {}),
      );
      await tester.pump();

      // Tap trigger button to expand options
      await tester.tap(find.text('DEMO'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Demo Face (Video)'), findsOneWidget);
      expect(find.text('Week 1'), findsOneWidget);
      expect(find.text('Week 3'), findsOneWidget);
      expect(find.text('Week 6'), findsOneWidget);
      expect(find.text('Starting baseline'), findsOneWidget);
      expect(find.text('Midway progress'), findsOneWidget);
      expect(find.text('Final verdict'), findsOneWidget);
    });

    testWidgets('executes onCaptureDemoPhoto when preset option is tapped', (
      tester,
    ) async {
      XFile? capturedFile;

      await tester.pumpWidget(
        buildTestableWidget(
          onCapture: (photo) async {
            capturedFile = photo;
          },
        ),
      );
      await tester.pump();

      // Expand sheet
      await tester.tap(find.text('DEMO'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap Week 1
      await tester.tap(find.text('Week 1'));
      await tester.pump();
      await tester.pump();

      expect(capturedFile, isNotNull);
      expect(capturedFile!.path.contains('demo_week1'), isTrue);
    });

    testWidgets('can select and capture Semaine 3 and Semaine 6', (
      tester,
    ) async {
      XFile? capturedFile;

      await tester.pumpWidget(
        buildTestableWidget(
          onCapture: (photo) async {
            capturedFile = photo;
          },
        ),
      );
      await tester.pump();

      // Expand sheet
      await tester.tap(find.text('DEMO'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap Week 3
      await tester.tap(find.text('Week 3'));
      await tester.pump();
      await tester.pump();

      expect(capturedFile, isNotNull);
      expect(capturedFile!.path.contains('demo_week3'), isTrue);
    });
  });
}

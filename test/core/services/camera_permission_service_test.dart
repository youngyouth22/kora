import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/services/camera_permission_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter.baseflow.com/permissions/methods');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'checkPermissionStatus':
              // 1 is PermissionStatus.granted in permission_handler
              return 1;
            case 'requestPermissions':
              return {1: 1};
            case 'openAppSettings':
              return true;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group(
    'DefaultCameraPermissionService Tests with permission_handler channel',
    () {
      test('requestCameraPermission returns true when granted', () async {
        const service = DefaultCameraPermissionService();
        final result = await service.requestCameraPermission();
        expect(result, isTrue);
      });

      test('isPermissionGranted returns true when granted', () async {
        const service = DefaultCameraPermissionService();
        final result = await service.isPermissionGranted();
        expect(result, isTrue);
      });

      test('isPermanentlyDenied returns false when granted', () async {
        const service = DefaultCameraPermissionService();
        final result = await service.isPermanentlyDenied();
        expect(result, isFalse);
      });

      test('openSettings delegates to platform openAppSettings', () async {
        const service = DefaultCameraPermissionService();
        final result = await service.openSettings();
        expect(result, isTrue);
      });
    },
  );
}

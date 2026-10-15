import 'package:get_it/get_it.dart';
import 'package:kora/features/guided_capture/guided_capture_injection.dart';
import 'package:kora/features/onboarding/onboarding_injection.dart';
import 'package:kora/features/splash/splash_injection.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Central entry point to register all application dependencies.
void configureDependencies() {
  initOnboardingInjection(sl);
  initSplashInjection(sl);
  initGuidedCaptureInjection(sl);
}

import 'package:get_it/get_it.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/auth/data/auth_api_repository.dart';
import 'package:opicproject/features/feed/data/feed_repository.dart';
import 'package:opicproject/features/onboarding/data/onboarding_repository.dart';
import 'package:opicproject/features/onboarding/data/onboarding_service.dart';

GetIt locator = GetIt.instance;

initLocator() {
  //onboarding repository
  locator.registerLazySingleton<OnboardingDataRepository>(
    () => OnboardingDataRepository(),
  );

  //onboarding service
  locator.registerLazySingleton<OnboardingService>(
    () => OnboardingService(locator<OnboardingDataRepository>()),
  );

  //feed repository
  locator.registerLazySingleton<FeedRepository>(() => FeedRepository());

  locator.registerLazySingleton<AuthRepository>(() => AuthRepository());
  locator.registerSingleton<AuthManager>(AuthManager());
}

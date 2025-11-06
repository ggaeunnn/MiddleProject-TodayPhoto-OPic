import 'package:get_it/get_it.dart';
import 'package:opicproject/features/feed/data/feed_repository.dart';
import 'package:opicproject/features/feed/data/feed_service.dart';
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

  //feed service
  locator.registerLazySingleton<FeedService>(
    () => FeedService(locator<FeedRepository>()),
  );
}

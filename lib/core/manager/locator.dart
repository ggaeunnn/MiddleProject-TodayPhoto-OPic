import 'package:get_it/get_it.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/alarm/data/alarm_repository.dart';
import 'package:opicproject/features/auth/data/auth_api_repository.dart';
import 'package:opicproject/features/feed/data/feed_repository.dart';
import 'package:opicproject/features/friend/data/friend_repository.dart';
import 'package:opicproject/features/home/data/home_repository.dart';
import 'package:opicproject/features/onboarding/data/onboarding_repository.dart';
import 'package:opicproject/features/post/data/post_repository.dart';
import 'package:opicproject/features/setting/data/setting_repository.dart';

GetIt locator = GetIt.instance;

initLocator() {
  //onboarding repository
  locator.registerLazySingleton<OnboardingDataRepository>(
    () => OnboardingDataRepository(),
  );

  //feed repository
  locator.registerLazySingleton<FeedRepository>(() => FeedRepository());

  locator.registerLazySingleton<AuthRepository>(() => AuthRepository());
  locator.registerSingleton<AuthManager>(AuthManager());

  locator.registerLazySingleton<PostRepository>(() => PostRepository());
  locator.registerLazySingleton<HomeRepository>(() => HomeRepository());
  locator.registerLazySingleton<FriendRepository>(() => FriendRepository());
  locator.registerLazySingleton<AlarmRepository>(() => AlarmRepository());
  locator.registerLazySingleton<SettingRepository>(() => SettingRepository());
}

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/models/page_model.dart';
import 'package:opicproject/features/auth/ui/login_page.dart';
import 'package:opicproject/features/home/main_page.dart';
import 'package:opicproject/features/onboarding/data/onboarding_service.dart';
import 'package:opicproject/features/onboarding/ui/onboarding_screen.dart';
import 'package:opicproject/features/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/manager/locator.dart';
import 'features/alarm/ui/alarm_list_page.dart';
import 'features/feed/data/feed_service.dart';
import 'features/feed/ui/feed.dart';
import 'features/feed/viewmodel/feed_viewmodel.dart';
import 'features/friend/ui/friend_page.dart';
import 'features/post/ui/post_detail_page.dart';
import 'features/setting/ui/setting_alarm_page.dart';
import 'features/setting/ui/setting_page.dart';

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/post_detail_page',
      builder: (context, state) => OnboardingScreen(),
    ),

    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/', builder: (context, state) => PostDetailScreen()),
    GoRoute(
      path: '/alarm_list_page',
      builder: (context, state) => AlarmListScreen(userId: 0),
    ),
    GoRoute(path: '/feed', builder: (context, state) => MyFeedScreen()),
    GoRoute(path: '/friend_page', builder: (context, state) => FriendScreen()),
    GoRoute(path: '/home', builder: (context, state) => MainPage()),
    GoRoute(
      path: '/setting_alarm_page',
      builder: (context, state) => SettingAlarmScreen(),
    ),
    GoRoute(
      path: '/setting_page',
      builder: (context, state) => SettingScreen(userId: 0),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //getIt 로케이터 초기화
  initLocator();
  await Supabase.initialize(
    url: 'https://zoqxnpklgtcqkvskarls.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
  );
  await dotenv.load(fileName: 'assets/config/.env');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          //getIt을 통한 서비스 주입
          create: (context) =>
              OnboardingViewModel(locator<OnboardingService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => FeedViewModel(locator<FeedService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => PageCountViewmodel(),
          child: MainPage(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

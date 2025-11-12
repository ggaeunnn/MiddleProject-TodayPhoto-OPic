import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/manager/firebase_manager.dart';
import 'package:opicproject/core/models/page_model.dart';
import 'package:opicproject/features/alarm/data/alarm_view_model.dart';
import 'package:opicproject/features/auth/ui/login_page.dart';
import 'package:opicproject/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:opicproject/features/friend/data/friend_view_model.dart';
import 'package:opicproject/features/home/main_page.dart';
import 'package:opicproject/features/home/viewmodel/home_viewmodel.dart';
import 'package:opicproject/features/onboarding/data/onboarding_service.dart';
import 'package:opicproject/features/onboarding/ui/onboarding_screen.dart';
import 'package:opicproject/features/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:opicproject/features/post/viewmodel/post_viewmodel.dart';
import 'package:opicproject/features/setting/data/setting_view_model.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/manager/locator.dart';
import 'features/alarm/ui/alarm_list_page.dart';
import 'features/feed/data/feed_viewmodel.dart';
import 'features/feed/ui/feed.dart';
import 'features/friend/ui/friend_page.dart';
import 'features/post/ui/post_detail_page.dart';
import 'features/setting/ui/setting_alarm_page.dart';
import 'features/setting/ui/setting_page.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드 메시지 처리 시 Firebase 초기화 보장
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
  // TODO: 백그라운드에서 실행시 로직 처리
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => OnboardingScreen()),

    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(
      path: '/post_detail_page/:id',
      builder: (context, state) {
        final postId = int.parse(state.pathParameters['id']!);
        return PostDetailScreen(postId: postId);
      },
    ),
    GoRoute(
      path: '/alarm_list_page',
      builder: (context, state) => AlarmListScreen(),
    ),
    GoRoute(
      path: '/feed/:id',
      builder: (context, state) {
        final userId = int.parse(state.pathParameters['id']!);
        return FeedScreen(userId: userId);
      },
    ),
    GoRoute(path: '/friend_page', builder: (context, state) => FriendScreen()),
    GoRoute(path: '/home', builder: (context, state) => MainPage()),
    GoRoute(
      path: '/setting_alarm_page',
      builder: (context, state) => SettingAlarmScreen(),
    ),
    GoRoute(
      path: '/setting_page',
      builder: (context, state) => SettingScreen(),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/config/.env");

  //firebase초기화
  await Firebase.initializeApp();
  await dotenv.load(fileName: 'assets/config/.env');

  await Supabase.initialize(
    url: 'https://zoqxnpklgtcqkvskarls.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
  );
  //백그라운드 핸들러
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //매니저 초기화(토큰/리스너 설정)
  await FirebaseManager().initialize();
  //getIt 로케이터 초기화
  initLocator();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          //getIt을 통한 서비스 주입
          create: (context) =>
              OnboardingViewModel(locator<OnboardingService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(),
          child: LoginScreen(),
        ),
        ChangeNotifierProvider(create: (context) => FeedViewModel()),
        ChangeNotifierProvider(
          create: (context) => PageCountViewmodel(),
          child: MainPage(),
        ),
        ChangeNotifierProvider(create: (context) => FriendViewModel()),
        ChangeNotifierProvider(create: (context) => PostViewModel()),
        ChangeNotifierProvider(create: (context) => HomeViewModel()),
        ChangeNotifierProvider(create: (context) => SettingViewModel()),
        ChangeNotifierProvider(create: (context) => AlarmViewModel()),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

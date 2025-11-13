import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:opicproject/core/manager/firebase_manager.dart';
import 'package:opicproject/core/manager/go_router_manager.dart';
import 'package:opicproject/features/alarm/data/alarm_view_model.dart';
import 'package:opicproject/features/auth/ui/login_page.dart';
import 'package:opicproject/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:opicproject/features/friend/data/friend_view_model.dart';
import 'package:opicproject/features/home/viewmodel/home_viewmodel.dart';
import 'package:opicproject/features/onboarding/data/onboarding_service.dart';
import 'package:opicproject/features/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:opicproject/features/post/viewmodel/post_viewmodel.dart';
import 'package:opicproject/features/setting/data/setting_view_model.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/manager/locator.dart';
import 'features/feed/data/feed_viewmodel.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드 메시지 처리 시 Firebase 초기화 보장
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
  // TODO: 백그라운드에서 실행시 로직 처리
}

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
        ChangeNotifierProvider(create: (context) => FriendViewModel()),
        ChangeNotifierProvider(create: (context) => PostViewModel()),
        ChangeNotifierProvider(create: (context) => HomeViewModel()),
        ChangeNotifierProvider(create: (context) => SettingViewModel()),
        ChangeNotifierProvider(create: (context) => AlarmViewModel()),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouterManager.router,
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

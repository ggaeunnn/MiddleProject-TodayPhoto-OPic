import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/manager/firebase_manager.dart';
import 'package:opicproject/core/manager/go_router_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/features/alarm/viewmodel/alarm_view_model.dart';
import 'package:opicproject/features/auth/data/auth_api_repository.dart';
import 'package:opicproject/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:opicproject/features/friend/viewmodel/friend_view_model.dart';
import 'package:opicproject/features/home/viewmodel/home_viewmodel.dart';
import 'package:opicproject/features/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:opicproject/features/post/viewmodel/post_viewmodel.dart';
import 'package:opicproject/features/setting/viewmodel/setting_view_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/manager/locator.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드 메시지 처리 시 Firebase 초기화 보장
  await Firebase.initializeApp();
  await dotenv.load(fileName: "assets/config/.env");

  await SupabaseManager().initialize();

  //백그라운드에서 실행시 앱실행과는 독립된 공간이므로 직접 레포지토리와 매니저를 등록해야함
  if (!GetIt.instance.isRegistered<AuthRepository>()) {
    GetIt.instance.registerLazySingleton<AuthRepository>(
      () => AuthRepository(),
    );

    GetIt.instance.registerSingleton<AuthManager>(AuthManager());
  }
  print("Handling a background message: ${message.messageId}");
  // TODO: 백그라운드에서 실행시 로직 처리
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/config/.env");

  //firebase초기화
  await Firebase.initializeApp();

  //supabase 초기화
  await SupabaseManager().initialize();

  //백그라운드 핸들러
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //매니저 초기화(토큰/리스너 설정,로컬 푸시 설정)
  await FirebaseManager().initialize();
  //getIt 로케이터 초기화
  initLocator();

  await [Permission.camera, Permission.photos].request();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthManager.shared),
        ChangeNotifierProvider(
          //getIt을 통한 서비스 주입
          create: (context) => OnboardingViewModel(),
        ),
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => FriendViewModel()),
        ChangeNotifierProvider(create: (context) => PostViewModel()),
        ChangeNotifierProvider(create: (context) => SettingViewModel()),
        ChangeNotifierProvider(create: (context) => AlarmViewModel()),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouterManager.router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Pretendard'),
      ),
    ),
  );
}

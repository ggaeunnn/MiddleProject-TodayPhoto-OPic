import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/alarm/ui/alarm_list_page.dart';
import 'package:opicproject/features/auth/ui/login_page.dart';
import 'package:opicproject/features/feed/ui/feed.dart';
import 'package:opicproject/features/feed/viewmodel/feed_viewmodel.dart';
import 'package:opicproject/features/friend/ui/friend_page.dart';
import 'package:opicproject/features/friend/viewmodel/friend_view_model.dart';
import 'package:opicproject/features/home/home.dart';
import 'package:opicproject/features/onboarding/ui/onboarding_screen.dart';
import 'package:opicproject/features/post/ui/post_detail_page.dart';
import 'package:opicproject/features/post_report/ui/post_report_page.dart';
import 'package:opicproject/features/setting/ui/setting_alarm_page.dart';
import 'package:opicproject/features/setting/ui/setting_page.dart';
import 'package:opicproject/main_page.dart';
import 'package:opicproject/splash_screen.dart';
import 'package:provider/provider.dart';

class GoRouterManager {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: AuthManager.shared,
    redirect: (context, state) {
      final isLoggedIn = AuthManager.shared.userInfo != null;
      final currentPath = state.matchedLocation;

      // 스플래시 리다이렉트 제외
      if (currentPath == '/splash') {
        return null;
      }

      if (!AuthManager.shared.isInitialized) {
        return null;
      }

      // 로그인 안하면 못들어가는 곳
      final lockedPaths = [
        '/friend',
        '/my-feed',
        '/setting',
        '/post_detail_page',
        '/alarm_list_page',
        '/setting_alarm_page',
      ];

      // 로그인 안됐는데 다른 탭 가려고 함
      if (!isLoggedIn &&
          lockedPaths.any((path) => currentPath.startsWith(path))) {
        return '/login';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      // Shell Route로 앱바+하단네비가 있는 메인 구조
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainPage(navigationShell: navigationShell);
        },
        branches: [
          // 홈 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) {
                  final topicIdString = state.uri.queryParameters['topicId'];
                  final topicId = topicIdString != null
                      ? int.tryParse(topicIdString)
                      : null;

                  return HomeScreen(key: ValueKey(topicId), topicId: topicId);
                },
                routes: [
                  GoRoute(
                    path: 'feed/:id',
                    builder: (context, state) {
                      final userId = int.parse(state.pathParameters['id']!);
                      return ChangeNotifierProvider(
                        create: (_) => FeedViewModel(),
                        child: FeedScreen(userId: userId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // 친구 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/friend',
                builder: (context, state) {
                  return ChangeNotifierProvider(
                    create: (_) => FriendViewModel(),
                    child: FriendScreen(),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'feed/:id',
                    builder: (context, state) {
                      final userId = int.parse(state.pathParameters['id']!);
                      return ChangeNotifierProvider(
                        create: (_) => FeedViewModel(),
                        child: FeedScreen(userId: userId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // 내 피드 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-feed',
                builder: (context, state) {
                  final loginUserId = AuthManager.shared.userInfo?.id ?? 0;
                  return ChangeNotifierProvider(
                    create: (_) => FeedViewModel(),
                    child: FeedScreen(userId: loginUserId),
                  );
                },
              ),
              GoRoute(
                path: '/report/:postId',
                builder: (context, state) {
                  final postId = int.parse(state.pathParameters['postId']!);
                  return PostReportScreen(postId: postId);
                },
              ),
            ],
          ),
          // 설정 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/setting',
                builder: (context, state) => SettingScreen(),
              ),
            ],
          ),
        ],
      ),

      // 전체화면 페이지들 (앱바/네비 없음)
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
        path: '/setting_alarm_page',
        builder: (context, state) => SettingAlarmScreen(),
      ),
    ],
  );
}

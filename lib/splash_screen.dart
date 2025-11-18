import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // AuthManager 초기화 대기
      final authManager = context.read<AuthManager>();

      // 최소 3초 동안 스플래시 표시
      await Future.wait([
        Future.delayed(const Duration(seconds: 5)),
        _waitForAuthInitialization(authManager),
      ]);

      if (mounted) {
        _navigateToNextScreen(authManager);
      }
    } catch (e) {
      debugPrint('Splash initialization error: $e');
      if (mounted) {
        context.go('/');
      }
    }
  }

  Future<void> _waitForAuthInitialization(AuthManager authManager) async {
    // AuthManager가 초기화될 때까지 대기
    while (!authManager.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _navigateToNextScreen(AuthManager authManager) {
    if (authManager.userInfo != null) {
      // 로그인되어 있으면 홈으로
      context.go('/home');
    } else {
      // 로그인 안 되어 있으면 온보딩으로
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.opicWhite,
      body: Center(
        child: Lottie.asset(
          'assets/animations/splash.json',
          width: 300,
          height: 300,
          fit: BoxFit.contain,
          repeat: true,
        ),
      ),
    );
  }
}

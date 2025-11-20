import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, AuthManager>(
      builder: (context, authViewModel, authManager, child) {
        final isLoggined = authManager.userInfo != null;
        return SafeArea(
          child: Scaffold(
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: AppColors.opicBackground,
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 120,
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Image.asset(
                            'assets/images/logo_square_skyblue.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const Text(
                          "오늘 한 장",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("📸 로그인해서 시작하세요 😘"),
                        const SizedBox(height: 40),

                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 50,
                              child: !isLoggined
                                  ? SignInGoogle()
                                  : SignOutGoogle(),
                            ),
                          ),
                        ),

                        if (authViewModel.isLoading)
                          Center(
                            child: CircularProgressIndicator(
                              color: AppColors.opicBlue,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SignInGoogle extends StatelessWidget {
  const SignInGoogle({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
      ),
      onPressed: () async {
        bool result = await authViewModel.signInGoogle();
        if (context.mounted && result) {
          context.go('/home');
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: AppColors.opicSoftBlue,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/google_logo.png',
                width: 30,
                height: 30,
              ),
              SizedBox(width: 10),
              Text(
                "구글 계정으로 로그인",
                style: TextStyle(color: AppColors.opicWhite, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignOutGoogle extends StatelessWidget {
  const SignOutGoogle({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();

    return ElevatedButton(
      onPressed: () async {
        bool result = await authViewModel.signOutGoogle();

        if (context.mounted && result) {
          context.go('/home');
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.opicRed),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.opicRed,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "로그아웃",
              style: TextStyle(color: AppColors.opicWhite, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

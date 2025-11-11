import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return SafeArea(
          child: Scaffold(
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: const Color(0xFFFCFCF0),
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
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 50,

                              child: const SignInGoogle(),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 50),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 50,

                              child: const SignOutGoogle(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (authViewModel.isLoading)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
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
      child: Image.asset('assets/images/sign_in_google.png'),
    );
  }
}

class SignOutGoogle extends StatelessWidget {
  const SignOutGoogle({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();

    return ElevatedButton(
      onPressed: () => authViewModel.signOutGoogle(),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.opicRed),
      ),
      child: const Text('로그아웃', style: TextStyle(color: AppColors.opicWhite)),
    );
  }
}

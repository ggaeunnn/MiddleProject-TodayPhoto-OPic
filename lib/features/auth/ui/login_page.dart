import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
                            child: Container(
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
                            child: Container(
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
        backgroundColor: MaterialStateProperty.all(AppColors.opicRed),
      ),
      child: const Text('로그아웃', style: TextStyle(color: AppColors.opicWhite)),
    );
  }
}

/*

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
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 50,
                              child: const SignInGoogle(),
                            ),
                          ),
                        ),
                        // --- SignOutGoogle 위젯 위치 유지 ---
                        // SignOutGoogle 내부에서는 context.read를 사용합니다.
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 50),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 50,
                              child: const SignOutGoogle(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 로딩 인디케이터: authViewModel.isLoading 값에 따라 표시
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
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
      ),
      onPressed: () async {
        /// Web Client ID that you registered with Google Cloud.
        */
/*const webClientId =
            '479616985373-kts5936rtob89ouk38mj1sjarf6aun7q.apps.googleusercontent.com';

        /// iOS Client ID that you registered with Google Cloud.
        const iosClientId =
            '692210323507-7b5ee32vdvfrp1ppn7rsanlcflcd20js.apps.googleusercontent.com';*/ /*

        String webClientId = dotenv.get("Web_Client_Id");
        String clientId = dotenv.get("Client_Id");
        final scopes = ['email', 'profile'];
        final googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize(
          serverClientId: webClientId,
          clientId: clientId,
        );

        //final googleUser = await googleSignIn.attemptLightweightAuthentication();
        try {
          final googleUser = await googleSignIn.authenticate();
          print("google user ${googleUser}");
          final authorization =
              await googleUser.authorizationClient.authorizationForScopes(
                scopes,
              ) ??
              await googleUser.authorizationClient.authorizeScopes(scopes);
          final idToken = googleUser.authentication.idToken;
          if (idToken == null) {
            Fluttertoast.showToast(msg: "로그인 실패");
            throw AuthException('No ID Token found.');
          }

          var aa = await SupabaseManager.shared.supabase.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: authorization.accessToken,
          );

          print("supabase user: ${aa.user}");
        } on GoogleSignInException catch (e) {
          print(e.description);
        }
        // or await googleSignIn.authenticate();which will return a GoogleSignInAccount or throw an exception
        */
/*
        print("google user ${googleUser}");
        if (googleUser == null) {
          Fluttertoast.showToast(msg: "로그인 실패");
          throw AuthException('Failed to sign in with Google.');
        }
        if (googleUser != null) {
          Fluttertoast.showToast(msg: "로그인 성공");
        }*/ /*


        /// Authorization is required to obtain the access token with the appropriate scopes for Supabase authentication,
        /// while also granting permission to access user information.
        */
/*final authorization =
            await googleUser.authorizationClient.authorizationForScopes(
              scopes,
            ) ??
            await googleUser.authorizationClient.authorizeScopes(scopes);
        final idToken = googleUser.authentication.idToken;
        if (idToken == null) {
          Fluttertoast.showToast(msg: "로그인 실패");
          throw AuthException('No ID Token found.');
        }
        if (idToken != null) {
          Fluttertoast.showToast(msg: "로그인 성공");
        }*/ /*

      },
      child: Image.asset('assets/images/sign_in_google.png'),
    );
  }
}

class SignOutGoogle extends StatelessWidget {
  const SignOutGoogle({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _SignOutGoogle,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(AppColors.opicRed),
      ),
      child: const Text('로그아웃', style: TextStyle(color: AppColors.opicWhite)),
    );
  }
}

Future<void> _nativeGoogleSignIn() async {
  final supabase = Supabase.instance.client;
  final scopes = ['email', 'profile'];
  final googleSignIn = GoogleSignIn.instance;
  await googleSignIn.initialize(serverClientId: dotenv.get("WEB_CLIENT_ID"));
  final googleUser = await googleSignIn.attemptLightweightAuthentication();
  print("googleUser : $googleUser");
  if (googleUser == null) {
    throw AuthException('Failed to sign in with Google.');
  }

  final authorization =
      await googleUser.authorizationClient.authorizationForScopes(scopes) ??
      await googleUser.authorizationClient.authorizeScopes(scopes);
  print("authorization : $authorization");

  final idToken = googleUser.authentication.idToken;
  print("idToken : $idToken");
  if (idToken == null) {
    throw AuthException('No ID Token found.');
  }
  final result = await supabase.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: authorization.accessToken,
  );
  print("result : $result");
}

Future<void> _SignOutGoogle() async {
  final supabase = Supabase.instance.client;
  await supabase.auth.signOut(); // 수파베이스
  await GoogleSignIn.instance.signOut(); // 구글 로그인 해당
  Fluttertoast.showToast(msg: "로그아웃 성공");
}
*/

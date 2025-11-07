import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();

    SupabaseManager.shared.supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        _userId = data.session?.user.id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Color(0xFFFCFCF0),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 120,
                      padding: EdgeInsets.only(bottom: 20),
                      child: Image.asset(
                        'assets/images/logo_square_skyblue.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      "오늘 한 장",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("📸 로그인해서 시작하세요 😘"),
                    SizedBox(height: 40),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 50,
                          child: SigninGoogle(),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 50),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 50,
                          child: SignOutGoogle(),
                        ),
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
  }
}

class SigninGoogle extends StatelessWidget {
  const SigninGoogle({super.key});

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
        const webClientId =
            '692210323507-s9fg7qm083lr7sndilqqdn06ciq1klgt.apps.googleusercontent.com';

        /// iOS Client ID that you registered with Google Cloud.
        const iosClientId =
            '692210323507-dfkoaem59ng2bvtajg3ajf6td9daqdsu.apps.googleusercontent.com';
        final scopes = ['email', 'profile'];
        final googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize(
          serverClientId: webClientId,
          clientId: iosClientId,
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
        /*
        print("google user ${googleUser}");
        if (googleUser == null) {
          Fluttertoast.showToast(msg: "로그인 실패");
          throw AuthException('Failed to sign in with Google.');
        }
        if (googleUser != null) {
          Fluttertoast.showToast(msg: "로그인 성공");
        }*/

        /// Authorization is required to obtain the access token with the appropriate scopes for Supabase authentication,
        /// while also granting permission to access user information.
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
        }*/
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
      child: const Text('로그아웃'),
    );
  }
}

Future<void> _SignOutGoogle() async {
  await SupabaseManager.shared.supabase.auth.signOut(); // 수파베이스
  await GoogleSignIn.instance.signOut(); // 구글 로그인 해당
  Fluttertoast.showToast(msg: "로그아웃 성공");
}

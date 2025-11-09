import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
                          child: SignInGoogle(),
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
        await _nativeGoogleSignIn();
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

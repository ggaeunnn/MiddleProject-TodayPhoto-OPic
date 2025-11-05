import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:opicproject/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OpicLoginPage extends StatefulWidget {
  const OpicLoginPage({super.key});

  @override
  State<OpicLoginPage> createState() => _OpicLoginPageState();
}

class _OpicLoginPageState extends State<OpicLoginPage> {
  String? _userId;

  @override
  void initState() {
    super.initState();

    supabase.auth.onAuthStateChange.listen((data) {
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
                      "오늘의 한 장",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("로그인해서 시작하세요"),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 50,
                    child: SigninGoogle(),
                  ),
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
        final googleUser = await googleSignIn
            .attemptLightweightAuthentication();
        // or await googleSignIn.authenticate(); which will return a GoogleSignInAccount or throw an exception
        if (googleUser == null) {
          throw AuthException('Failed to sign in with Google.');
        }

        /// Authorization is required to obtain the access token with the appropriate scopes for Supabase authentication,
        /// while also granting permission to access user information.
        final authorization =
            await googleUser.authorizationClient.authorizationForScopes(
              scopes,
            ) ??
            await googleUser.authorizationClient.authorizeScopes(scopes);
        final idToken = googleUser.authentication.idToken;
        if (idToken == null) {
          throw AuthException('No ID Token found.');
        }
        await supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: authorization.accessToken,
        );
      },
      child: Image.asset('assets/images/sign_in_google.png'),
    );
  }
}

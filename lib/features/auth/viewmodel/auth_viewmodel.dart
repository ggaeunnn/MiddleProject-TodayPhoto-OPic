import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/features/auth/data/auth_api_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository = GetIt.instance<AuthRepository>();
  final googleSignIn = GoogleSignIn.instance;
  final scopes = ['email', 'profile'];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  AuthViewModel() {
    debugPrint('AuthViewmodel');
    initGoogleSignIn();
  }

  //구글로그인 초기화
  Future<void> initGoogleSignIn() async {
    await dotenv.load(fileName: "assets/config/.env");

    await googleSignIn.initialize(
      serverClientId: dotenv.get("Web_Client_Id"),
      clientId: dotenv.get("Client_Id"),
    );
  }

  //구글로그인
  Future<GoogleAuthTokens?> _getGoogleAuthTokens() async {
    //구글 로그인
    final googleUser = await googleSignIn.authenticate();

    debugPrint("google user $googleUser");

    //엑세스토큰을 받기위한 인증절차
    final authorization =
        await googleUser.authorizationClient.authorizationForScopes(scopes) ??
        await googleUser.authorizationClient.authorizeScopes(scopes);
    debugPrint("authorization : $authorization");
    final idToken = googleUser.authentication.idToken;

    if (idToken == null) {
      Fluttertoast.showToast(msg: "로그인 실패: 토큰 누락");
      throw AuthException('Required tokens (ID/Access) not found.');
    }
    debugPrint("idToken : $idToken");
    return GoogleAuthTokens(
      idToken: idToken,
      accessToken: authorization.accessToken,
    );
  }

  //supabase 로그인(토큰)
  Future<void> _signInWithSupabaseIdToken({
    required String idToken,
    required String accessToken,
  }) async {
    AuthResponse response = await SupabaseManager.shared.supabase.auth
        .signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );

    debugPrint("supabase user: ${response.user}");
  }

  //앱로그인(구글)
  Future<bool> signInGoogle() async {
    try {
      _setLoading(true); // 로딩 시작
      final tokens = await _getGoogleAuthTokens();

      if (tokens == null) {
        return false;
      }

      await _signInWithSupabaseIdToken(
        idToken: tokens.idToken,
        accessToken: tokens.accessToken,
      );

      final currentSession =
          SupabaseManager.shared.supabase.auth.currentSession;

      if (currentSession != null) {
        return true;
      }
      return false;
    } on GoogleSignInException catch (e) {
      debugPrint("GoogleSignInException: ${e.description}");
      Fluttertoast.showToast(msg: "구글 로그인 중 오류 발생");
      return false;
    } on AuthException catch (e) {
      debugPrint("Auth flow error: ${e.message}");
      Fluttertoast.showToast(msg: "인증 오류 발생: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("An unexpected error occurred: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOutGoogle() async {
    _setLoading(true);
    try {
      final supabase = SupabaseManager.shared.supabase.auth;
      final googleSignInInstance = GoogleSignIn.instance;

      await supabase.signOut();

      await googleSignInInstance.signOut();

      Fluttertoast.showToast(msg: "로그아웃 성공");
    } catch (e) {
      debugPrint("Sign out error: $e");
      Fluttertoast.showToast(msg: "로그아웃 중 오류 발생");
    } finally {
      _setLoading(false);
    }
  }
}

class GoogleAuthTokens {
  final String idToken;
  final String accessToken;

  GoogleAuthTokens({required this.idToken, required this.accessToken});
}

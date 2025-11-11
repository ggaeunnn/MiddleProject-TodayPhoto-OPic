import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/core/models/user_model.dart';
import 'package:opicproject/features/auth/data/auth_api_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthManager extends ChangeNotifier {
  static final AuthManager _shared = AuthManager();

  static AuthManager get shared => _shared;

  UserInfo? userInfo;
  SupabaseClient supabase = SupabaseManager.shared.supabase;

  AuthManager() {
    SupabaseManager.shared.supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event; //auth상태
      final session = data.session; // 세션
      String? uuid;
      print("Auth상태 변화 - 이벤트: $event");

      // auth상태에 따른 분기
      switch (event) {
        case AuthChangeEvent.signedIn:
          // 사용자 로그인 (처음 로그인, 재시작 후 세션 복구 포함)
          print("인증매니저:AuthChangeEvent.signedIn");

          uuid = data.session?.user.id;

          fetchUser(uuid!);

          notifyListeners();
          break;

        case AuthChangeEvent.signedOut:
          // 사용자 로그아웃
          print("인증매니저:AuthChangeEvent.signedOut");

          uuid = null;

          userInfo = null;
          notifyListeners();
          break;

        case AuthChangeEvent.tokenRefreshed:
          // 세션이 만료되어 토큰만 갱신된 경우
          print("인증매니저:AuthChangeEvent.tokenRefreshed");
          break;

        case AuthChangeEvent.initialSession:
          // 앱 시작 시 기존 세션 확인 및 복구 완료
          if (session != null) {
            //로그아웃 하지않고 앱 종료 했었더라면
            print('인증매니저:초기 세션 복구 성공.');

            uuid = data.session?.user.id;

            fetchUser(uuid!);
            notifyListeners();
          } else {
            //로그아웃을 하고 앱을 종료했다면
            print('인증매니저: 초기 세션 없음 (로그아웃 상태)');
          }
          break;

        case AuthChangeEvent.userUpdated:

          // 사용자 정보 (이메일, 비밀번호 등)가 업데이트된 경우
          print('인증매니저: 사용자 정보 업데이트됨.');
          notifyListeners();
          break;

        case AuthChangeEvent.passwordRecovery:
          // 비밀번호 복구 요청 (이메일 확인 단계)
          print('인증매니저: 비밀번호 복구 요청됨.');
          notifyListeners();
          break;

        case AuthChangeEvent.userDeleted:
          // TODO: Handle this case.
          break;
        case AuthChangeEvent.mfaChallengeVerified:
          // TODO: Handle this case.
          break;
      }
    });
  }

  Future<void> fetchUser(String uuid) async {
    UserInfo result = await GetIt.instance<AuthRepository>()
        .fetchUserDataWithUUID(uuid);
    debugPrint("유저 가져오기:${result.email}");
    userInfo = result;
    notifyListeners();
  }
}

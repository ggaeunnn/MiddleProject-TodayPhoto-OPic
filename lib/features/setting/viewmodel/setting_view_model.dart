import 'package:flutter/foundation.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/models/alarm_setting_model.dart';
import 'package:opicproject/core/models/user_model.dart';
import 'package:opicproject/features/setting/data/nickname_check_state.dart';

import '../data/setting_repository.dart';

class SettingViewModel extends ChangeNotifier {
  final SettingRepository _repository = SettingRepository();

  // 로그인 유저 정보
  UserInfo? _loginUser;
  UserInfo? get loginUser => _loginUser;

  // 유저의 알림 세팅
  AlarmSetting? _alarmSetting;
  AlarmSetting? get alarmSetting => _alarmSetting;

  // 닉네임 체크 상태
  NicknameCheckState _nicknameCheckState = const NicknameCheckState.idle();
  NicknameCheckState get nicknameCheckState => _nicknameCheckState;

  // 로딩 상태
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 로그인 유저 정보 불러오기
  Future<void> fetchUserInfo(int userId) async {
    _loginUser = await _repository.fetchAUser(userId);
    notifyListeners();
  }

  // 닉네임 중복 체크
  Future<bool> checkNicknameAvailability(
    String nickname,
    int currentUserId,
  ) async {
    // 현재 닉네임과 동일하면 중복 아님
    if (_loginUser?.nickname == nickname) {
      _nicknameCheckState = const NicknameCheckState.current();
      notifyListeners();
      return false;
    }

    final exists = await _repository.isNicknameExists(
      nickname,
      excludeUserId: currentUserId,
    );

    _nicknameCheckState = exists
        ? const NicknameCheckState.duplicate()
        : const NicknameCheckState.available();

    notifyListeners();
    return exists;
  }

  // 닉네임 체크 상태 업데이트
  void updateNicknameCheckState(NicknameCheckState state) {
    _nicknameCheckState = state;
    notifyListeners();
  }

  // 닉네임 변경하기
  Future<bool> updateNickname(int userId, String nickname) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = await _repository.updateNickname(userId, nickname);

      if (updatedUser != null) {
        _loginUser = updatedUser;
        AuthManager.shared.updateUserInfo(updatedUser);
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 푸시 알람 설정 불러오기
  Future<void> fetchAlarmSetting(int userId) async {
    _alarmSetting = await _repository.fetchAlarmSetting(loginId: userId);
    notifyListeners();
  }

  // 푸시 알람 설정 업데이트
  Future<void> updateAlarmSetting({
    required int userId,
    required AlarmSetting newSetting,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateAlarmSetting(userId, newSetting);
      _alarmSetting = newSetting;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

import 'package:opicproject/core/manager/dio_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/core/models/alarm_setting_model.dart';
import 'package:opicproject/core/models/user_model.dart';

class SettingRepository {
  // 유저 정보 가져오기
  Future<UserInfo?> fetchAUser(int userId) async {
    return await SupabaseManager.shared.fetchAUser(userId);
  }

  // 해당 닉네임 여부 확인
  Future<bool> checkIfExist(String userNickname) async {
    return await SupabaseManager.shared.checkIfExist(userNickname);
  }

  // 닉네임 변경하기
  Future<void> editNickname(int loginUserId, String newNickname) async {
    await SupabaseManager.shared.editNickname(loginUserId, newNickname);
  }

  // 알람 설정 가져오기
  Future<AlarmSetting?> fetchAlarmSetting(int loginId) async {
    return await DioManager.shared.fetchAlarmSetting(loginId: loginId);
  }

  // 알람 설정 업데이트 추가
  Future<void> updateAlarmSetting(int userId, AlarmSetting setting) async {
    await SupabaseManager.shared.updateAlarmSetting(userId, setting);
  }
}

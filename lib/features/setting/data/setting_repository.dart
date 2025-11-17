import 'package:dio/dio.dart';
import 'package:opicproject/core/manager/dio_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/core/models/alarm_setting_model.dart';
import 'package:opicproject/core/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingRepository {
  final Dio _dio = DioManager.shared.dio;
  final SupabaseClient _supabase = SupabaseManager.shared.supabase;

  // 특정 유저 정보 가져오기
  Future<UserInfo?> fetchAUser(int userId) async {
    final Map<String, dynamic>? data = await _supabase
        .from("user")
        .select('*')
        .eq('id', userId)
        .maybeSingle();
    if (data == null) {
      return null;
    }
    return UserInfo.fromJson(data);
  }

  // 해당 닉네임을 사용하는 사용자가 있는지 확인하기
  Future<bool> isNicknameExists(String nickname, {int? excludeUserId}) async {
    if (excludeUserId != null) {
      final List<dynamic> data = await _supabase
          .from("user")
          .select('id')
          .eq('nickname', nickname);

      final filtered = data
          .where((user) => user['id'] != excludeUserId)
          .toList();
      return filtered.isNotEmpty;
    } else {
      final Map<String, dynamic>? data = await _supabase
          .from("user")
          .select('*')
          .eq('nickname', nickname)
          .maybeSingle();
      return data != null;
    }
  }

  // 닉네임 변경하기
  // 닉네임 변경하기
  Future<UserInfo?> updateNickname(int userId, String nickname) async {
    await _supabase
        .from('user')
        .update({'nickname': nickname})
        .eq('id', userId);
    return await fetchAUser(userId);
  }

  // 로그인 유저의 푸시 알림 설정 정보 가져오기
  Future<AlarmSetting?> fetchAlarmSetting({required int loginId}) async {
    final response = await _dio.get(
      '/alarm_setting',
      queryParameters: {'select': '*', 'user_id': 'eq.$loginId', 'limit': '1'},
      options: Options(),
    );

    if (response.data != null &&
        response.data is List &&
        (response.data as List).isNotEmpty) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return AlarmSetting.fromJson(dataList.first);
    }
    return null;
  }

  // 푸시 알림 설정 업데이트
  Future<void> updateAlarmSetting(int userId, AlarmSetting setting) async {
    await _supabase
        .from('alarm_setting')
        .update({
          'entire_alarm': setting.entireAlarm,
          'new_topic': setting.newTopic,
          'like_post': setting.likePost,
          'new_comment': setting.newComment,
          'new_request': setting.newRequest,
          'new_friend': setting.newFriend,
          'edited_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId);
  }
}

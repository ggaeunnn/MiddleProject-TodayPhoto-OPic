import 'package:flutter/foundation.dart';
import 'package:opicproject/core/models/alarm_model.dart';
import 'package:opicproject/core/models/alarm_setting_model.dart';
import 'package:opicproject/core/models/post_model.dart';
import 'package:opicproject/core/models/topic_model.dart';
import 'package:opicproject/core/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static final SupabaseManager _shared = SupabaseManager();

  static SupabaseManager get shared => _shared;

  // Get a reference your Supabase client
  final supabase = Supabase.instance.client;

  SupabaseManager() {
    debugPrint("SupabaseManager init");
  }

  /// 오늘의 주제 가져오기
  Future<Topic?> fetchATopic(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final startOfNextDay = DateTime(date.year, date.month, date.day + 1);

    final Map<String, dynamic>? data = await supabase
        .from("topic")
        .select('content')
        .gte('uploaded_at', startOfDay.toIso8601String())
        .lt('uploaded_at', startOfNextDay.toIso8601String())
        .maybeSingle();

    if (data == null) {
      return null;
    }
    return Topic.fromJson(data);
  }

  // 특정 유저 정보 가져오기 (아이디로)
  Future<UserInfo?> fetchAUser(int userId) async {
    final Map<String, dynamic>? data = await supabase
        .from("user")
        .select('*')
        .eq('id', userId)
        .maybeSingle();
    if (data == null) {
      return null;
    }
    return UserInfo.fromJson(data);
  }

  // 친구 관계 여부 확인하기
  Future<bool> checkIfFriend(int loginUserId, int friendUserId) async {
    final Map<String, dynamic>? data = await supabase
        .from("friends")
        .select('*')
        .or(
          'and(user1_id.eq.$loginUserId,user2_id.eq.$friendUserId), and(user1_id.eq.$friendUserId,user2_id.eq.$loginUserId)',
        )
        .maybeSingle();
    if (data == null) {
      return false;
    }
    return true;
  }

  // 해당 닉네임을 사용하는 사용자 존재 여부 확인
  Future<bool> checkIfExist(String userNickname) async {
    final Map<String, dynamic>? data = await supabase
        .from("user")
        .select('*')
        .eq('nickname', userNickname)
        .maybeSingle();
    if (data == null) {
      return false;
    }
    return true;
  }

  // 특정 유저 정보 가져오기 (닉네임으로)
  Future<UserInfo?> fetchAUserByName(String userNickname) async {
    final Map<String, dynamic>? data = await supabase
        .from("user")
        .select('*')
        .eq('nickname', userNickname)
        .maybeSingle();
    if (data == null) {
      return null;
    }
    return UserInfo.fromJson(data);
  }

  // 친구 요청 하기
  Future<void> makeARequest(int loginUserId, int targetUserId) async {
    await supabase.from('friend_request').insert({
      "created_at": "${DateTime.now()}",
      "request_id": loginUserId,
      "target_id": targetUserId,
    });
  }

  // 친구 요청 응답하기
  Future<void> answerARequest(int requestId) async {
    await supabase
        .from('friend_request')
        .update({'answered_at': "${DateTime.now()}"})
        .eq('id', requestId);
  }

  // 친구 요청 취소하기
  Future<void> deleteARequest(int loginId, int userId) async {
    await supabase
        .from("friend_request")
        .delete()
        .eq('request_id', loginId)
        .eq('target_id', userId);
  }

  // 친구 요청 승낙 - 친구 추가
  Future<void> acceptARequest(
    int requestId,
    int loginUserId,
    int requesterId,
  ) async {
    await supabase.from('friends').insert({
      'created_at': "${DateTime.now()}",
      'user1_id': loginUserId,
      'user2_id': requesterId,
    });
  }

  // 닉네임 수정
  Future<UserInfo?> editNickname(int loginUserId, String nickname) async {
    await supabase
        .from('user')
        .update({'nickname': nickname})
        .eq('id', loginUserId);
    return await fetchAUser(loginUserId);
  }

  // 알람 설정 업데이트
  Future<void> updateAlarmSetting(int userId, AlarmSetting setting) async {
    await supabase
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

  // 특정 알림 정보 가져오기 (아이디로)
  Future<Alarm?> fetchAnAlarm(int alarmId) async {
    final Map<String, dynamic>? data = await supabase
        .from("alarm")
        .select('*')
        .eq('id', alarmId)
        .maybeSingle();
    if (data == null) {
      return null;
    }
    return Alarm.fromJson(data);
  }

  // 알람 메세지 읽음 처리
  Future<void> checkAlarm(int alarmId) async {
    await supabase.from('alarm').update({'is_checked': true}).eq('id', alarmId);
  }

  // 차단 여부 확인하기
  Future<bool> checkIfBlocked(int loginId, int userId) async {
    final data = await supabase
        .from("block")
        .select('id')
        .eq('user_id', loginId)
        .eq('blocked_user', userId)
        .maybeSingle();
    if (data == null) {
      return false;
    }
    return true;
  }

  // 상대가 날 차단했는지 확인하기
  Future<bool> checkIfBlockedMe(int loginId, int userId) async {
    final data = await supabase
        .from("block")
        .select('id')
        .eq('user_id', userId)
        .eq('blocked_user', loginId)
        .maybeSingle();
    if (data == null) {
      return false;
    }
    return true;
  }

  // 차단하기
  Future<void> blockUser(int loginId, int userId) async {
    await supabase.from("block").insert({
      'user_id': loginId,
      'blocked_user': userId,
      'blocked_at': DateTime.now().toIso8601String(),
    });
  }

  // 차단해제하기
  Future<void> unblockUser(int loginId, int userId) async {
    await supabase
        .from("block")
        .delete()
        .eq('user_id', loginId)
        .eq('blocked_user', userId);
  }

  // 친구 요청 중 여부 확인하기
  Future<bool> checkIfRequested(int loginId, int userId) async {
    final data = await supabase
        .from("friend_request")
        .select('id')
        .isFilter('answered_at', null)
        .or(
          'and(request_id.eq.$loginId,target_id.eq.$userId),and(request_id.eq.$userId,target_id.eq.$loginId)',
        )
        .maybeSingle();

    return data != null;
  }

  // 특정 알림 정보 가져오기 (아이디로)
  Future<Post?> fetchPostWriterId(int postId) async {
    final Map<String, dynamic>? data = await supabase
        .from("posts")
        .select('*')
        .eq('id', postId)
        .maybeSingle();
    if (data == null) {
      return null;
    }
    return Post.fromJson(data);
  }
}

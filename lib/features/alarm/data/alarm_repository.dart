import 'package:dio/dio.dart';
import 'package:opicproject/core/manager/dio_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/core/models/alarm_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlarmRepository {
  final Dio _dio = DioManager.shared.dio;
  final SupabaseClient _supabase = SupabaseManager.shared.supabase;

  // 알람 리스트 불러오기
  Future<List<Alarm>> fetchAlarms({
    required int currentPage,
    int perPage = 10,
    required int loginId,
  }) async {
    final int startIndex = perPage * (currentPage - 1);
    final int endIndex = startIndex + perPage - 1;
    final String range = "$startIndex-$endIndex";

    final response = await _dio.get(
      '/alarm?select=*&user_id=eq.$loginId&is_checked=eq.false',
      options: Options(headers: {'Range': range}),
    );

    if (response.data != null) {
      final List data = response.data;
      final List<Alarm> results = data.map((json) {
        return Alarm.fromJson(json);
      }).toList();
      return results;
    } else {
      return List.empty();
    }
  }

  // 특정 알림 정보 가져오기 (아이디로)
  Future<Alarm?> fetchAnAlarm(int alarmId) async {
    final Map<String, dynamic>? data = await _supabase
        .from("alarm")
        .select('*')
        .eq('id', alarmId)
        .maybeSingle();
    if (data == null) {
      return null;
    }
    return Alarm.fromJson(data);
  }

  // 알람 메세지 읽음 처리하기
  Future<void> checkAlarm(int alarmId) async {
    await _supabase
        .from('alarm')
        .update({'is_checked': true})
        .eq('id', alarmId);
  }
}

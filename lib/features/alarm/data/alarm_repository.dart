import 'package:opicproject/core/manager/dio_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/core/models/alarm_model.dart';

class AlarmRepository {
  // 알람 리스트 불러오기
  Future<List<Alarm>> fetchAlarms(int currentPage, int loginUserId) async {
    return await DioManager.shared.fetchAlarms(
      currentPage: currentPage,
      loginId: loginUserId,
    );
  }

  // 알람 하나 정보 불러오기
  Future<Alarm?> fetchAnAlarm(int alarmId) async {
    return await SupabaseManager.shared.fetchAnAlarm(alarmId);
  }

  // 알람 확인처리하기
  Future<void> checkAlarm(int alarmId) async {
    return await SupabaseManager.shared.checkAlarm(alarmId);
  }
}

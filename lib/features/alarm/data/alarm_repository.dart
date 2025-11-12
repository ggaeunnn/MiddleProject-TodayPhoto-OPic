import 'package:opicproject/core/manager/dio_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/core/models/alarm_model.dart';

class AlarmRepository {
  Future<List<Alarm>> fetchAlarms(int currentPage, int loginUserId) async {
    return await DioManager.shared.fetchAlarms(
      currentPage: currentPage,
      loginId: loginUserId,
    );
  }

  Future<Alarm?> fetchAnAlarm(int alarmId) async {
    return await SupabaseManager.shared.fetchAnAlarm(alarmId);
  }

  Future<void> checkAlarm(int alarmId) async {
    return await SupabaseManager.shared.checkAlarm(alarmId);
  }
}

import 'package:flutter/foundation.dart';
import 'package:opicproject/core/models/topic_model.dart';
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

  /// 유저 정보 가져오기
}

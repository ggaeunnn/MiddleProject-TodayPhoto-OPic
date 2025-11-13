import 'package:dio/dio.dart';
import 'package:opicproject/core/models/alarm_model.dart';
import 'package:opicproject/core/models/alarm_setting_model.dart';
import 'package:opicproject/core/models/block_model.dart';
import 'package:opicproject/core/models/friend_model.dart';
import 'package:opicproject/core/models/friend_request_model.dart';
import 'package:opicproject/core/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DioManager {
  static final DioManager shared = DioManager._internal();

  factory DioManager() => shared;

  DioManager._internal();

  // ✅ Dio를 처음 사용할 때 자동으로 생성
  Dio get _dio {
    final supabase = Supabase.instance.client;

    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://zoqxnpklgtcqkvskarls.supabase.co/rest/v1',
        headers: {
          'apikey':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = supabase.auth.currentSession;

          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }

          return handler.next(options);
        },
      ),
    );

    return dio;
  }

  // 친구 목록 불러오기
  Future<List<Friend>> fetchFriends({
    int currentPage = 1,
    int perPage = 5,
    required int loginId,
  }) async {
    final int startIndex = perPage * (currentPage - 1);
    final int endIndex = startIndex + perPage - 1;
    final String range = "$startIndex-$endIndex";

    final response = await _dio.get(
      'https://zoqxnpklgtcqkvskarls.supabase.co/rest/v1/friends?select=*&or=(user1_id.eq.$loginId,user2_id.eq.$loginId)',
      options: Options(
        headers: {
          'apikey':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
          'Range': range,
        },
      ),
    );

    if (response.data != null) {
      final List data = response.data;
      final List<Friend> results = data.map((json) {
        return Friend.fromJson(json);
      }).toList();
      return results;
    } else {
      return List.empty();
    }
  }

  // 친구 요청 목록 불러오기
  Future<List<FriendRequest>> fetchFriendRequests({
    int currentPage = 1,
    int perPage = 5,
    required int loginId,
  }) async {
    final int startIndex = perPage * (currentPage - 1);
    final int endIndex = startIndex + perPage - 1;
    final String range = "$startIndex-$endIndex";

    final response = await _dio.get(
      'https://zoqxnpklgtcqkvskarls.supabase.co/rest/v1/friend_request',
      queryParameters: {
        'select': '*',
        'target_id': 'eq.$loginId',
        'answered_at': 'is.null',
      },
      options: Options(
        headers: {
          'apikey':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
          'Range': range,
        },
      ),
    );

    if (response.data != null) {
      final List data = response.data;
      final List<FriendRequest> results = data.map((json) {
        return FriendRequest.fromJson(json);
      }).toList();
      return results;
    } else {
      return List.empty();
    }
  }

  // 알람 설정 가져오기
  Future<AlarmSetting?> fetchAlarmSetting({required int loginId}) async {
    try {
      final response = await _dio.get(
        'https://zoqxnpklgtcqkvskarls.supabase.co/rest/v1/alarm_setting',
        queryParameters: {
          'select': '*',
          'user_id': 'eq.$loginId',
          'limit': '1', // 단일 결과만 가져오기
        },
        options: Options(
          headers: {
            'apikey':
                'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
            'Authorization':
                'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
          },
        ),
      );

      if (response.data != null &&
          response.data is List &&
          (response.data as List).isNotEmpty) {
        final List<dynamic> dataList = response.data as List<dynamic>;
        return AlarmSetting.fromJson(dataList.first); // 첫 번째 항목만 반환
      } else {
        return null; // 데이터가 없으면 null 반환
      }
    } catch (e) {
      rethrow; // 또는 적절한 에러 처리
    }
  }

  // 알람 리스트 불러오기
  Future<List<Alarm>> fetchAlarms({
    int currentPage = 1,
    int perPage = 10,
    required int loginId,
  }) async {
    final int startIndex = perPage * (currentPage - 1);
    final int endIndex = startIndex + perPage - 1;
    final String range = "$startIndex-$endIndex";

    final response = await _dio.get(
      'https://zoqxnpklgtcqkvskarls.supabase.co/rest/v1/alarm',
      queryParameters: {
        'select': '*',
        'user_id': 'eq.$loginId',
        'is_checked': 'eq.false',
      },
      options: Options(
        headers: {
          'apikey':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
          'Range': range,
        },
      ),
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

  // 유저의 포스트 불러오기 FOR 피드
  Future<List<Post>> fetchPosts({
    int currentPage = 1,
    int perPage = 15,
    required int userId,
  }) async {
    final int startIndex = perPage * (currentPage - 1);
    final int endIndex = startIndex + perPage - 1;
    final String range = "$startIndex-$endIndex";

    final response = await _dio.get(
      'https://zoqxnpklgtcqkvskarls.supabase.co/rest/v1/posts',
      queryParameters: {
        'select': '*',
        'user_id': 'eq.$userId',
        'is_deleted': 'eq.false',
        'order': 'created_at.desc',
      },
      options: Options(
        headers: {
          'apikey':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
          'Range': range,
        },
      ),
    );

    if (response.data != null) {
      final List data = response.data;
      final List<Post> results = data.map((json) {
        return Post.fromJson(json);
      }).toList();
      return results;
    } else {
      return List.empty();
    }
  }

  // 유저가 차단한 사용자 불러오기
  Future<List<Block>> fetchBlockUsers({required int userId}) async {
    final response = await _dio.get(
      'https://zoqxnpklgtcqkvskarls.supabase.co/rest/v1/block',
      queryParameters: {'select': '*', 'user_id': 'eq.$userId'},
      options: Options(
        headers: {
          'apikey':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
        },
      ),
    );

    if (response.data != null) {
      final List data = response.data;
      final List<Block> results = data.map((json) {
        return Block.fromJson(json);
      }).toList();
      return results;
    } else {
      return List.empty();
    }
  }

  // 유저가 차단했거나, 유저가 차단당한 사용자 불러오기
  Future<List<Block>> fetchBlockOrBlockedUsers({required int userId}) async {
    final response = await _dio.get(
      'https://zoqxnpklgtcqkvskarls.supabase.co/rest/v1/block',
      queryParameters: {
        'select': '*',
        'or': '(user_id.eq.$userId,blocked_user_id.eq.$userId)',
      },
      options: Options(
        headers: {
          'apikey':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXhucGtsZ3RjcWt2c2thcmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTk4NTYsImV4cCI6MjA3ODA3NTg1Nn0.qR8GmGNztCm44qqm7xJK4VvmI1RcIJybGKeMVBy8yaA',
        },
      ),
    );

    if (response.data != null) {
      final List data = response.data;
      final List<Block> results = data.map((json) {
        return Block.fromJson(json);
      }).toList();
      return results;
    } else {
      return List.empty();
    }
  }
}

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';

class FirebaseManager {
  // 1. 싱글톤 인스턴스
  static final FirebaseManager _instance = FirebaseManager._internal();
  factory FirebaseManager() => _instance;
  FirebaseManager._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// 🚀 FCM 서비스를 초기화하고 리스너를 설정하는 메인 함수
  Future<void> initialize() async {
    // 주의: 백그라운드 핸들러 등록은 main.dart에서 처리됨

    // iOS 포그라운드 알림 표시 설정 (iOS에서 포그라운드 알림 팝업을 띄우기 위해 필수)
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 1. 권한 요청
    await _requestPermission();

    // 2. 토큰 가져오기 및 리스너 설정
    await _getToken();
    _setupTokenRefreshListener();

    // 3. 알림 수신 리스너 설정
    _setupMessageListeners();
  }

  // --- 권한 및 토큰 관리 ---

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('User granted FCM permission: ${settings.authorizationStatus}');
  }

  Future<void> _getToken() async {
    _fcmToken = await _fcm.getToken();
    print("Initial FCM Token: $_fcmToken");
    // TODO: 획득한 토큰을 백엔드 서버로 전송하는 API 호출 로직을 여기에 구현하세요.
  }

  void _setupTokenRefreshListener() {
    _fcm.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print("Token Refreshed: $newToken");
      // TODO: 새로 갱신된 토큰을 서버에 전송하는 API 호출 로직을 여기에 구현하세요.
    });
  }

  // --- 메시지 리스너 설정 ---

  void _setupMessageListeners() {
    // 🔔 1. 포그라운드 메시지 (앱 실행 중)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('=== FOREGROUND MESSAGE RECEIVED ===');
      print('Title: ${message.notification?.title}');
      print('Data: ${message.data}');

      // TODO: flutter_local_notifications 패키지를 사용해 사용자에게 로컬 알림을 표시합니다.
    });

    // 👆 2. 알림 탭 이벤트 리스너 (Background 상태에서 알림 탭 시)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('=== MESSAGE OPENED APP (BACKGROUND) ===');
      print('Data: ${message.data}');
      // TODO: 메시지 데이터를 기반으로 특정 화면으로 이동하는 라우팅 로직을 구현합니다.
    });

    // 🚪 3. 앱이 완전히 종료(Terminated) 상태일 때 알림을 탭하면 메시지를 가져옴
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('=== INITIAL MESSAGE (TERMINATED) ===');
        print('Data: ${message.data}');
        // TODO: 앱 시작 시 메시지 데이터를 처리하고 라우팅하는 로직을 구현합니다.
      }
    });
  }

  Future<void> updateFCMToken(String uuid) async {
    final tokenToSave = _fcmToken;

    if (tokenToSave == null) {
      print('FCM 토큰이 아직 설정되지 않아 Supabase 업데이트를 건너뜁니다. (uuid: $uuid)');
      return;
    }

    try {
      // 2. 클래스 멤버인 tokenToSave(_fcmToken) 값을 사용하여 업데이트
      final response = await SupabaseManager.shared.supabase
          .from('user')
          .update({'token': tokenToSave})
          .eq('uuid', uuid)
          .select();

      // Supabase 업데이트가 성공적으로 완료된 후의 로그
      print('FCM Token 업데이트 완료. uuid: $uuid, token: $tokenToSave');
    } catch (error) {
      // 업데이트 중 에러 발생 시 로그
      print('FCM 토큰 업데이트 에러 for uuid $uuid: $error');
    }
  }

  Future<void> deleteFCMToken(String uuid) async {
    try {
      // 2. 클래스 멤버인 tokenToSave(_fcmToken) 값을 사용하여 업데이트
      final response = await SupabaseManager.shared.supabase
          .from('user')
          .update({'token': ''})
          .eq('uuid', uuid)
          .select();

      // Supabase 업데이트가 성공적으로 완료된 후의 로그
      debugPrint('FCM Token 제거 완료. uuid: $uuid');
    } catch (error) {
      // 업데이트 중 에러 발생 시 로그
      debugPrint('FCM 토큰 제거 에러 for uuid $uuid: $error');
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:opicproject/core/manager/go_router_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';

class FirebaseManager {
  // 1. 싱글톤 인스턴스
  static final FirebaseManager _instance = FirebaseManager._internal();
  factory FirebaseManager() => _instance;
  FirebaseManager._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  //토큰
  String? _fcmToken;
  //토큰 getter
  String? get fcmToken => _fcmToken;
  //로컬 push
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  //FCM 서비스를 초기화하고 리스너를 설정하는 함수
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

    //3.로컬알림 초기화
    _initialization();

    // 4. 알림 수신 리스너 설정
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
    //포그라운드 메시지 (앱 실행 중)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('=== FOREGROUND MESSAGE RECEIVED ===');

      sendLocalPushFromFCM(message);
    });

    //알림 탭 이벤트 리스너 (Background 상태에서 알림 탭 시)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('=== MESSAGE OPENED APP (BACKGROUND) ===');
      handleRemoteMessageRouting(message);
    });

    // 앱이 완전히 종료(Terminated) 상태일 때 알림을 탭하면 메시지를 가져옴
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('=== INITIAL MESSAGE (TERMINATED) ===');
        handleRemoteMessageRouting(message);
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
      //클래스 멤버인 tokenToSave(_fcmToken) 값을 사용하여 업데이트
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
      //클래스 멤버인 tokenToSave(_fcmToken) 값을 사용하여 업데이트
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

  //로컬 푸시 초기화. android와 ios각각 설정해야함
  //ios는 지금 설정안되어있음
  void _initialization() async {
    AndroidInitializationSettings android = const AndroidInitializationSettings(
      "logo_android",
    );
    DarwinInitializationSettings ios = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    InitializationSettings settings = InitializationSettings(
      android: android,
      iOS: ios,
    );
    await _local.initialize(
      settings,
      //메시지를 눌렀을때 실행될 콜백함수를 넣어야함
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  //fcm의 데이터에서 deepLinkData를 뽑아 alarmType을 분기로 gorouter용 라우팅경로 생성
  String _generateRoute(String alarmType, Map<String, dynamic> deepLinkData) {
    switch (alarmType) {
      case 'NEW_FRIEND_REQUEST':
        // 친구 요청 페이지나 알림 목록 페이지로 이동
        return '/friend';
      case 'NEW_REPLY':
      case 'NEW_LIKE':
        // 게시물 ID를 사용하여 해당 게시물 상세 페이지로 이동
        final String postId = deepLinkData['post_id']?.toString() ?? '0';
        return '/post_detail_page/$postId';
      case 'NEW_FRIEND':
        // 친구 목록 페이지로 이동
        final String friendId = deepLinkData['friend_id']?.toString() ?? '0';
        return '/friend/feed/$friendId';
      default:
        return '/home';
    }
  }

  // 로컬 알림을 눌렀을 때 페이지 이동 콜백 (FCM 데이터 처리용으로 개선)
  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    final String? payload = notificationResponse.payload;

    if (payload != null && payload.isNotEmpty) {
      try {
        //데이터 파싱
        final Map<String, dynamic> fcmData = jsonDecode(payload);

        final String alarmType = fcmData['alarm_type'] ?? 'UNKNOWN';

        //alarm_id, post_id, friend_id 등의 정보를 포함한 최종 라우트 생성
        //안드로이드에서 로컬푸시생성시 반드시 고유한 아이디가 필요해서 alarm테이블의 기본키를 사용할것
        final String targetRoute = _generateRoute(alarmType, fcmData);

        //GoRouter를 사용하여 해당 경로로 이동 (push 대신 go를 사용할 수도 있음)
        GoRouterManager.router.push(targetRoute);

        print('알림탭. 경로: $targetRoute');
      } catch (e) {
        print('알림처리중 에러: $e');
      }
    }
  }

  //백그라운드,또는 앱이 죽어있을때 메시지에서 라우팅
  void handleRemoteMessageRouting(RemoteMessage message) {
    final Map<String, dynamic> fcmData = message.data;
    final String alarmType = fcmData['alarm_type']?.toString() ?? 'UNKNOWN';

    // _generateRoute 함수를 사용하여 알림 타입과 데이터에 맞는 라우팅 경로 생성
    final String targetRoute = _generateRoute(alarmType, fcmData);

    GoRouterManager.router.push(targetRoute);
    print('FCM 탭으로 라우팅 성공: $targetRoute');
  }

  // FCM 메시지를 받아 로컬 푸시
  void sendLocalPushFromFCM(RemoteMessage message) async {
    final Map<String, dynamic> fcmData = message.data;

    final String title = message.notification?.title ?? "새로운 알림";
    final String body = message.notification?.body ?? "알림 내용";

    //데이터 파싱
    final String payloadString = jsonEncode(fcmData);

    NotificationDetails details = const NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      android: AndroidNotificationDetails(
        // 채널 ID는 FCM과 Local Notification이 동일한 채널을 사용하도록 일관성 있게 유지하는 것이 좋음
        "fcm_notification_channel", //채널아이디
        "일반 알림", //채널이름
        channelDescription: "새로운 알림 및 업데이트", //채널설명
        importance: Importance.max, //중요도
        priority: Priority.high,
      ),
    );

    await _local.show(
      // 알림 ID는 고유해야 하기때문에 데이터베이스의 alarm_id를 사용
      int.tryParse(fcmData['alarm_id'] ?? '1') ?? 1,
      title,
      body,
      details,
      payload: payloadString,
    );

    print('로컬알림 발송. 데이터: $payloadString');
  }
}

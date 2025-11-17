import 'package:opicproject/core/models/alarm_setting_model.dart';

class AlarmState {
  final bool entireAlarm;
  final bool newTopic;
  final bool likePost;
  final bool newComment;
  final bool newRequest;
  final bool newFriend;

  const AlarmState({
    required this.entireAlarm,
    required this.newTopic,
    required this.likePost,
    required this.newComment,
    required this.newRequest,
    required this.newFriend,
  });

  const AlarmState.initial()
    : entireAlarm = true,
      newTopic = true,
      likePost = true,
      newComment = true,
      newRequest = true,
      newFriend = true;

  AlarmSetting toAlarmSetting(int userId) {
    return AlarmSetting(
      id: userId - 8,
      userId: userId,
      entireAlarm: entireAlarm,
      newTopic: newTopic,
      likePost: likePost,
      newComment: newComment,
      newRequest: newRequest,
      newFriend: newFriend,
      createdAt: '',
    );
  }

  static AlarmState fromAlarmSetting(AlarmSetting setting) {
    return AlarmState(
      entireAlarm: setting.entireAlarm,
      newTopic: setting.newTopic,
      likePost: setting.likePost,
      newComment: setting.newComment,
      newRequest: setting.newRequest,
      newFriend: setting.newFriend,
    );
  }

  AlarmState updateEntireAlarm(bool value) {
    if (!value) {
      return const AlarmState(
        entireAlarm: false,
        newTopic: false,
        likePost: false,
        newComment: false,
        newRequest: false,
        newFriend: false,
      );
    }
    return AlarmState(
      entireAlarm: value,
      newTopic: newTopic,
      likePost: likePost,
      newComment: newComment,
      newRequest: newRequest,
      newFriend: newFriend,
    );
  }

  AlarmState updateIndividual(String type, bool value) {
    bool newEntireAlarm = entireAlarm;
    bool updatedNewTopic = newTopic;
    bool updatedLikePost = likePost;
    bool updatedNewComment = newComment;
    bool updatedNewRequest = newRequest;
    bool updatedNewFriend = newFriend;

    switch (type) {
      case 'newTopic':
        updatedNewTopic = value;
        break;
      case 'likePost':
        updatedLikePost = value;
        break;
      case 'newComment':
        updatedNewComment = value;
        break;
      case 'newRequest':
        updatedNewRequest = value;
        break;
      case 'newFriend':
        updatedNewFriend = value;
        break;
    }

    // 하나라도 켜지면 전체 알람도 자동으로 켬
    if (value) {
      newEntireAlarm = true;
    }

    // 모든 하위 알람이 꺼지면 전체 알람도 끔
    if (!updatedNewTopic &&
        !updatedLikePost &&
        !updatedNewComment &&
        !updatedNewRequest &&
        !updatedNewFriend) {
      newEntireAlarm = false;
    }

    return AlarmState(
      entireAlarm: newEntireAlarm,
      newTopic: updatedNewTopic,
      likePost: updatedLikePost,
      newComment: updatedNewComment,
      newRequest: updatedNewRequest,
      newFriend: updatedNewFriend,
    );
  }
}

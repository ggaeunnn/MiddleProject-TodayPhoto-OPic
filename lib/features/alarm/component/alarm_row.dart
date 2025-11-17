// alarm_row.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/alarm/data/alarm_view_model.dart';
import 'package:opicproject/features/alarm/util/date_check.dart';
import 'package:opicproject/features/friend/data/friend_view_model.dart';
import 'package:opicproject/features/post/ui/post_detail_page.dart';
import 'package:provider/provider.dart';

class AlarmRow extends StatelessWidget {
  final int alarmId;
  final int loginUserId;

  const AlarmRow({super.key, required this.alarmId, required this.loginUserId});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AlarmViewModel>();

    // alarms 리스트에서 해당 알람 찾기
    final alarm = viewModel.alarms.where((a) => a.id == alarmId).firstOrNull;

    // 알람을 찾지 못한 경우
    if (alarm == null) {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Center(
          child: Text(
            "알림을 불러올 수 없습니다",
            style: TextStyle(fontSize: 13, color: AppColors.opicCoolGrey),
          ),
        ),
      );
    }

    final alarmType = alarm.alarmType;
    final alarmContent = alarm.content;
    final alarmTime = alarm.createdAt;
    final timeText = alarmTime.isNotEmpty
        ? TimeAgoUtil.getTimeAgo(alarmTime)
        : "오류발생";

    final friendId = alarm.friendId;
    final postId = alarm.postId;

    return GestureDetector(
      onTap: () {
        final friendViewModel = context.read<FriendViewModel>();
        final alarmViewModel = context.read<AlarmViewModel>();

        switch (alarmType) {
          case "NEW_TOPIC":
            context.pop();
            context.go('/home');
            alarmViewModel.checkAlarm(loginUserId, alarmId);
            break;

          case "NEW_FRIEND_REQUEST":
            context.pop();
            context.go('/friend');
            friendViewModel.changeTab(1);
            alarmViewModel.checkAlarm(loginUserId, alarmId);
            break;

          case "NEW_FRIEND":
            if (friendId != null) {
              context.pop();
              context.go('/home/feed/$friendId');
              alarmViewModel.checkAlarm(loginUserId, alarmId);
            } else {
              showToast("친구 정보를 찾을 수 없습니다");
            }
            break;

          case "NEW_LIKE":
            if (postId != null) {
              context.pop();
              context.push('/post_detail_page/$postId');
              alarmViewModel.checkAlarm(loginUserId, alarmId);
            } else {
              showToast("게시물을 찾을 수 없습니다");
            }
            break;

          case "NEW_REPLY":
            if (postId != null) {
              context.pop();
              context.push('/post_detail_page/$postId');
              alarmViewModel.checkAlarm(loginUserId, alarmId);
            } else {
              showToast("게시물을 찾을 수 없습니다");
            }
            break;

          default:
            showToast("오류 발생");
            break;
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.opicLightBlack, width: 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            spacing: 15,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.opicWarmGrey,
                child: switch (alarmType) {
                  "NEW_TOPIC" => Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: AppColors.opicBlue,
                  ),
                  "NEW_FRIEND_REQUEST" => Icon(
                    Icons.person_add_alt,
                    size: 20,
                    color: AppColors.opicBlue,
                  ),
                  "NEW_FRIEND" => Icon(
                    Icons.check,
                    size: 20,
                    color: AppColors.opicBlue,
                  ),
                  "NEW_LIKE" => Icon(
                    Icons.favorite_border_rounded,
                    size: 20,
                    color: AppColors.opicBlue,
                  ),
                  "NEW_REPLY" => Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 20,
                    color: AppColors.opicBlue,
                  ),
                  _ => Icon(
                    Icons.notifications,
                    size: 20,
                    color: AppColors.opicBlue,
                  ),
                },
              ),
              Column(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Text(
                      alarmContent,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: AppColors.opicBlack,
                      ),
                    ),
                  ),
                  Text(
                    timeText,
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 10,
                      color: AppColors.opicBlack,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

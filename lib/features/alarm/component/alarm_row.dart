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
    viewModel.fetchAnAlarm(this.alarmId);
    final alarm = viewModel.certainAlarm;
    final alarmId = alarm?.id ?? 0;
    final loginUserId = this.loginUserId;
    final alarmType = alarm?.alarmType;
    final alarmContent = alarm?.content ?? "존재하지 않는 알림입니다";
    final alarmTime = alarm?.createdAt ?? "";
    final timeText = alarmTime != ""
        ? TimeAgoUtil.getTimeAgo(alarmTime)
        : "오류발생";

    final friendId = alarm?.friendId;
    final postId = alarm?.postId;

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
            context.pop();
            context.go('/home/feed/$friendId');
            alarmViewModel.checkAlarm(loginUserId, alarmId);
            break;
          case "NEW_LIKE":
            context.pop();
            context.push('/post_detail_page/$postId');

            /// 해당 게시물을 보여줘야함
            alarmViewModel.checkAlarm(loginUserId, alarmId);
            break;
          case "NEW_REPLY":
            context.pop();
            context.push('/post_detail_page/$postId');

            /// 해당 게시물로 이동해야함
            alarmViewModel.checkAlarm(loginUserId, alarmId);
            break;
          case null:
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
                  null => Icon(
                    Icons.question_mark_rounded,
                    size: 20,
                    color: AppColors.opicBlue,
                  ),
                  String() => throw UnimplementedError(),
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

import 'package:flutter/material.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/alarm/data/alarm_view_model.dart';
import 'package:provider/provider.dart';

class AlarmRow extends StatelessWidget {
  final int alarmId;
  const AlarmRow({super.key, required this.alarmId});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<AlarmViewModel>();
    viewModel.fetchAnAlarm(alarmId);
    final alarm = viewModel.certainAlarm;
    final alarmType = alarm?.alarmType;
    final alarmContent = alarm?.content ?? "존재하지 않는 알림입니다";
    final alarmTime = alarm?.createdAt;

    return Container(
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
                  "n시간 전",
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:opicproject/core/app_colors.dart';

class AlarmRowTopic extends StatelessWidget {
  const AlarmRowTopic({super.key, alarmId, userId, topicId});

  @override
  Widget build(BuildContext context) {
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
              child: Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: AppColors.opicBlue,
              ),
            ),
            Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Text(
                    "새로운 주제가 도착했어요! [topicId.content]",
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

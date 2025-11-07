import 'package:flutter/material.dart';
import 'package:opicproject/core/app_colors.dart';

class AlarmRowLike extends StatelessWidget {
  const AlarmRowLike({super.key, alarmId, userId, postId});

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
                Icons.favorite_border_rounded,
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
                    "userId.nickname님이 회원님의 게시물을 좋아합니다",
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

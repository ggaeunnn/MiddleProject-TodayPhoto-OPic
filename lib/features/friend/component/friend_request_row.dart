import 'package:flutter/material.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/friend/viewmodel/friend_view_model.dart';
import 'package:opicproject/features/post/ui/post_detail_page.dart';
import 'package:provider/provider.dart';

class FriendRequestRow extends StatelessWidget {
  final int userId;
  final int requestId;
  final int requesterId;
  final String requesterNickname;
  const FriendRequestRow({
    super.key,
    required this.userId,
    required this.requestId,
    required this.requesterId,
    required this.requesterNickname,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.opicWhite,
              borderRadius: BorderRadius.all(Radius.circular(24)),
              border: Border.all(color: AppColors.opicSoftBlue, width: 0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Icon(
                        Icons.account_circle_rounded,
                        size: 40,
                        color: AppColors.opicBlue,
                      ),
                      Text(
                        requesterNickname,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: AppColors.opicBlack,
                        ),
                      ),
                    ],
                  ),
                  _buttonBuilder(
                    context,
                    viewModel,
                    requestId,
                    userId,
                    requesterId,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _buttonBuilder(
  BuildContext context,
  FriendViewModel viewModel,
  int requestId,
  int loginUserId,
  int requesterId,
) {
  return Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    spacing: 10,
    children: [
      Expanded(
        child: ElevatedButton(
          onPressed: () async {
            await viewModel.acceptARequest(requestId, loginUserId, requesterId);
            showToast("친구가 되었어요 😘");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.opicSoftBlue,
            foregroundColor: AppColors.opicWhite,
            padding: EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 15,
                color: AppColors.opicWhite,
              ),
              Text(
                "수락",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.opicWhite,
                ),
              ),
            ],
          ),
        ),
      ),
      Expanded(
        child: ElevatedButton(
          onPressed: () async {
            await viewModel.answerARequest(requestId, loginUserId);
            showToast("친구 요청을 거절했어요");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.opicWarmGrey,
            foregroundColor: AppColors.opicWhite,
            padding: EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                Icon(
                  Icons.highlight_remove_rounded,
                  size: 20,
                  color: AppColors.opicBlack,
                ),
                Text(
                  "거절",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.opicBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

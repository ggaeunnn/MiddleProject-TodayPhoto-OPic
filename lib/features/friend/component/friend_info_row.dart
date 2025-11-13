import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/component/yes_or_close_pop_up.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/friend/data/friend_view_model.dart';
import 'package:opicproject/features/post/ui/post_detail_page.dart';
import 'package:provider/provider.dart';

class FriendInfoRow extends StatelessWidget {
  final int userId;
  final int friendId;
  final int friendUserId;
  final String friendNickname;

  const FriendInfoRow({
    super.key,
    required this.userId,
    required this.friendId,
    required this.friendUserId,
    required this.friendNickname,
  });

  @override
  Widget build(BuildContext context) {
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
                    friendNickname,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: AppColors.opicBlack,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/friend/feed/$friendUserId');
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
                            Icons.photo,
                            size: 15,
                            color: AppColors.opicWhite,
                          ),
                          Text(
                            "피드 방문하기",
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
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black.withOpacity(0.6),
                        builder: (context) => YesOrClosePopUp(
                          title: "친구를 삭제하시겠어요?",
                          text: "삭제 시, 상대방과의 친구 관계가 끊어집니다",
                          confirmText: "삭제하기",
                          onConfirm: () {
                            context.pop();
                            context.read<FriendViewModel>().deleteFriend(
                              friendId,
                              userId,
                            );
                            showToast("선택한 사용자를 친구 목록에서 삭제했어요");
                          },
                          onCancel: () {
                            context.pop();
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.opicRed,
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
                            color: AppColors.opicWhite,
                          ),
                          Text(
                            "삭제",
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

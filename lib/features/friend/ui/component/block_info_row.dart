import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/component/yes_or_close_pop_up.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/friend/viewmodel/friend_view_model.dart';
import 'package:opicproject/features/post/ui/post_detail_page.dart';
import 'package:provider/provider.dart';

class BlockInfoRow extends StatelessWidget {
  final int userId;
  final int blockId;
  final int blockUserId;
  final String blockUserNickname;

  const BlockInfoRow({
    super.key,
    required this.userId,
    required this.blockId,
    required this.blockUserId,
    required this.blockUserNickname,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    blockUserNickname,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: AppColors.opicBlack,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.6),
                    builder: (context) => YesOrClosePopUp(
                      title: "차단을 해제하시겠어요?",
                      text: "선택한 사용자의 게시물이 다시 보여요",
                      confirmText: "차단 해제",
                      onConfirm: () async {
                        context.pop();
                        await context.read<FriendViewModel>().unblockUser(
                          userId,
                          blockUserId,
                        );
                        showToast("선택한 사용자를 차단 해제했어요");
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

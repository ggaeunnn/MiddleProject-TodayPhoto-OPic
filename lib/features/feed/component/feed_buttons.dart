import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/component/yes_or_close_pop_up.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/models/user_model.dart';
import 'package:opicproject/features/feed/viewmodel/feed_viewmodel.dart';
import 'package:opicproject/features/friend/viewmodel/friend_view_model.dart';
import 'package:opicproject/features/post/ui/post_detail_page.dart';
import 'package:provider/provider.dart';

class FeedButtons extends StatelessWidget {
  final UserInfo feedUser;
  final int loginUserId;

  const FeedButtons({
    super.key,
    required this.feedUser,
    required this.loginUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<FeedViewModel, FriendViewModel>(
      builder: (context, feedViewModel, friendViewModel, child) {
        final isBlocked = feedViewModel.relationState.isBlocked;
        final isFriend = friendViewModel.isFriend;
        final isRequested = feedViewModel.relationState.isRequested;

        return Row(
          spacing: 5,
          children: [
            // 친구 추가 버튼
            if (!isFriend && !isRequested)
              _buildAddFriendButton(context, feedViewModel, friendViewModel),
            // 친구 요청 취소 버튼
            if (!isFriend && isRequested)
              _buildCancelRequestButton(context, feedViewModel),
            // 차단 해제 버튼
            if (isBlocked) _buildUnblockButton(context, feedViewModel),
            // 차단 버튼
            if (!isBlocked) _buildBlockButton(context, feedViewModel),
          ],
        );
      },
    );
  }

  Widget _buildAddFriendButton(
    BuildContext context,
    FeedViewModel feedViewModel,
    FriendViewModel friendViewModel,
  ) {
    return GestureDetector(
      onTap: () =>
          _showAddFriendDialog(context, feedViewModel, friendViewModel),
      child: _buildActionButton(
        icon: Icons.person_add_alt_rounded,
        label: "친구 요청",
        color: AppColors.opicBlue,
      ),
    );
  }

  Widget _buildCancelRequestButton(
    BuildContext context,
    FeedViewModel feedViewModel,
  ) {
    return GestureDetector(
      onTap: () => _showCancelRequestDialog(context, feedViewModel),
      child: _buildActionButton(
        icon: Icons.check_circle_outline_rounded,
        label: "요청 취소",
        color: AppColors.opicCoolGrey,
      ),
    );
  }

  Widget _buildUnblockButton(
    BuildContext context,
    FeedViewModel feedViewModel,
  ) {
    return GestureDetector(
      onTap: () => _showUnblockDialog(context, feedViewModel),
      child: _buildActionButton(
        icon: Icons.check_circle_outline_rounded,
        label: "차단해제",
        color: AppColors.opicCoolGrey,
      ),
    );
  }

  Widget _buildBlockButton(BuildContext context, FeedViewModel feedViewModel) {
    return GestureDetector(
      onTap: () => _showBlockDialog(context, feedViewModel),
      child: _buildActionButton(
        icon: Icons.block_rounded,
        label: "차단하기",
        color: AppColors.opicRed,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.opicWhite, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              decoration: TextDecoration.none,
              color: AppColors.opicWhite,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog(
    BuildContext context,
    FeedViewModel feedViewModel,
    FriendViewModel friendViewModel,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => YesOrClosePopUp(
        title: "친구가 되시겠어요?",
        text: "상대방이 친구 요청을 수락하면, 친구가 되어요",
        confirmText: "친구 요청",
        onConfirm: () async {
          context.pop();
          await friendViewModel.makeARequest(loginUserId, feedUser.id);
          await feedViewModel.checkUserStatus(loginUserId, feedUser.id);
          await friendViewModel.checkIfFriend(loginUserId, feedUser.id);
          showToast("친구 요청을 보냈어요 💌");
        },
        onCancel: () => context.pop(),
      ),
    );
  }

  void _showCancelRequestDialog(
    BuildContext context,
    FeedViewModel feedViewModel,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => YesOrClosePopUp(
        title: "친구 요청을 취소하시겠어요?",
        text: "친구 요청을 취소할 수 있어요",
        confirmText: "요청 취소",
        onConfirm: () async {
          context.pop();
          await feedViewModel.deleteARequest(loginUserId, feedUser.id);
          showToast("친구 요청을 취소했어요");
        },
        onCancel: () => context.pop(),
      ),
    );
  }

  void _showUnblockDialog(BuildContext context, FeedViewModel feedViewModel) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => YesOrClosePopUp(
        title: "차단을 해제하시겠어요?",
        text: "해당 사용자의 게시물이 다시 보여요",
        confirmText: "차단해제",
        onConfirm: () async {
          context.pop();
          await feedViewModel.unblockUser(loginUserId, feedUser.id);
          await feedViewModel.checkUserStatus(loginUserId, feedUser.id);
          showToast("사용자를 차단해제했어요");
        },
        onCancel: () => context.pop(),
      ),
    );
  }

  void _showBlockDialog(BuildContext context, FeedViewModel feedViewModel) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => YesOrClosePopUp(
        title: "차단하시겠어요?",
        text: "앞으로 해당 사용자의 게시물은 보이지 않아요",
        confirmText: "차단하기",
        onConfirm: () async {
          context.pop();
          await feedViewModel.blockUser(loginUserId, feedUser.id);
          await feedViewModel.checkUserStatus(loginUserId, feedUser.id);
          showToast("사용자를 차단했어요");
        },
        onCancel: () => context.pop(),
      ),
    );
  }
}

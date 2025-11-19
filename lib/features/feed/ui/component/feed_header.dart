import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/models/user_model.dart';
import 'package:opicproject/features/feed/ui/component/feed_buttons.dart';
import 'package:opicproject/features/feed/viewmodel/feed_viewmodel.dart';
import 'package:opicproject/features/friend/viewmodel/friend_view_model.dart';
import 'package:provider/provider.dart';

class FeedHeader extends StatelessWidget {
  final UserInfo feedUser;
  final int loginUserId;

  const FeedHeader({
    super.key,
    required this.feedUser,
    required this.loginUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isMyFeed = feedUser.id == loginUserId;

    return Consumer2<FeedViewModel, FriendViewModel>(
      builder: (context, feedViewModel, friendViewModel, child) {
        final feedCount = feedViewModel.posts.length;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.opicWhite,
            border: Border(
              top: BorderSide(color: AppColors.opicSoftBlue, width: 0.5),
              bottom: BorderSide(color: AppColors.opicSoftBlue, width: 0.5),
            ),
          ),
          width: double.maxFinite,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNicknameSection(context, isMyFeed),
                    if (!isMyFeed)
                      FeedButtons(feedUser: feedUser, loginUserId: loginUserId),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  "게시물 $feedCount",
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: AppColors.opicSoftBlue,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNicknameSection(BuildContext context, bool isMyFeed) {
    return Row(
      children: [
        if (!isMyFeed)
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppColors.opicBlack),
            onPressed: () => context.pop(),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
          )
        else
          const SizedBox(width: 5.0),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(
            feedUser.nickname,
            style: TextStyle(
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              fontSize: 23,
              color: AppColors.opicBlack,
            ),
          ),
        ),
      ],
    );
  }
}

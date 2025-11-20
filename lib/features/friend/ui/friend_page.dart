import 'package:flutter/material.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/friend/data/friend_extension.dart';
import 'package:opicproject/features/friend/ui/component/friend_info_row.dart';
import 'package:opicproject/features/friend/ui/component/friend_request_row.dart';
import 'package:opicproject/features/friend/ui/component/friend_screen_header.dart';
import 'package:opicproject/features/friend/ui/component/refreshable_list_view.dart';
import 'package:opicproject/features/friend/viewmodel/friend_view_model.dart';
import 'package:provider/provider.dart';

import 'component/block_info_row.dart';

class FriendScreen extends StatelessWidget {
  const FriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<FriendViewModel>(
          builder: (context, viewModel, _) {
            final authManager = context.watch<AuthManager>();
            final loginUserId = authManager.userInfo?.id ?? 0;

            if (loginUserId == 0) {
              return _buildLoginRequiredView();
            }

            return Column(
              children: [
                const FriendScreenHeader(),
                Expanded(
                  child: Container(
                    color: AppColors.opicBackground,
                    child: _buildTabContent(viewModel, loginUserId),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginRequiredView() {
    return Container(
      decoration: BoxDecoration(color: AppColors.opicBackground),
      child: const Center(child: Text("로그인 해주세요")),
    );
  }

  Widget _buildTabContent(FriendViewModel viewModel, int loginUserId) {
    return switch (viewModel.tabNumber) {
      0 => _buildFriendList(viewModel, loginUserId),
      1 => _buildFriendRequestList(viewModel, loginUserId),
      2 => _buildBlockList(viewModel, loginUserId),
      int() => throw UnimplementedError(),
    };
  }

  Widget _buildFriendList(FriendViewModel viewModel, int loginUserId) {
    return RefreshableListView(
      itemCount: viewModel.friends.length,
      controller: viewModel.friendsScrollController,
      emptyMessage: '친구 목록이 비어있습니다',
      onRefresh: () => viewModel.refresh(loginUserId),
      itemBuilder: (context, index) {
        final friend = viewModel.friends[index];
        final friendUserId = friend.getOtherUserId(loginUserId);
        final friendInfo = viewModel.userInfoCache[friendUserId];
        final friendNickname = friendInfo?.nickname ?? "알 수 없음";

        return Container(
          color: AppColors.opicBackground,
          child: FriendInfoRow(
            userId: loginUserId,
            friendId: friend.id,
            friendUserId: friendUserId,
            friendNickname: friendNickname,
          ),
        );
      },
    );
  }

  Widget _buildFriendRequestList(FriendViewModel viewModel, int loginUserId) {
    return RefreshableListView(
      itemCount: viewModel.friendRequests.length,
      controller: viewModel.requestsScrollController,
      emptyMessage: '새로운 친구 요청이 없습니다',
      onRefresh: () => viewModel.refresh(loginUserId),
      itemBuilder: (context, index) {
        final friendRequest = viewModel.friendRequests[index];
        final requesterId = friendRequest.requestId;
        final requesterInfo = viewModel.userInfoCache[requesterId];
        final requesterNickname = requesterInfo?.nickname ?? "알 수 없음";

        return Container(
          color: AppColors.opicBackground,
          child: FriendRequestRow(
            userId: loginUserId,
            requestId: friendRequest.id,
            requesterNickname: requesterNickname,
            requesterId: requesterId,
          ),
        );
      },
    );
  }

  Widget _buildBlockList(FriendViewModel viewModel, int loginUserId) {
    return RefreshableListView(
      itemCount: viewModel.blockUsers.length,
      controller: viewModel.blocksScrollController,
      emptyMessage: '차단한 유저가 없습니다',
      onRefresh: () => viewModel.refresh(loginUserId),
      itemBuilder: (context, index) {
        final block = viewModel.blockUsers[index];
        final blockUserId = block.blockedUserId;
        final blockUserInfo = viewModel.userInfoCache[blockUserId];
        final blockUserNickname = blockUserInfo?.nickname ?? "알 수 없음";

        return Container(
          color: AppColors.opicBackground,
          child: BlockInfoRow(
            userId: loginUserId,
            blockId: block.id,
            blockUserId: blockUserId,
            blockUserNickname: blockUserNickname,
          ),
        );
      },
    );
  }
}

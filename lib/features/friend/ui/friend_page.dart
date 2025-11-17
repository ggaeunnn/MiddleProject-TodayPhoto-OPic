import 'package:flutter/material.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/friend/component/add_friend_pop_up.dart';
import 'package:opicproject/features/friend/component/block_info_row.dart';
import 'package:opicproject/features/friend/component/friend_info_row.dart';
import 'package:opicproject/features/friend/component/friend_request_row.dart';
import 'package:opicproject/features/friend/viewmodel/friend_view_model.dart';
import 'package:provider/provider.dart';

class FriendScreen extends StatelessWidget {
  const FriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<FriendViewModel>(
          builder: (context, viewModel, child) {
            final authManager = context.watch<AuthManager>();
            final loginUserId = authManager.userInfo?.id ?? 0;

            if (loginUserId == 0) {
              return Container(
                decoration: BoxDecoration(color: AppColors.opicBackground),
                child: Center(child: Text("로그인 해주세요")),
              );
            }

            return Column(
              children: [
                _buildHeader(context, viewModel),
                Expanded(
                  child: Container(
                    color: AppColors.opicBackground,
                    child: switch (viewModel.tabNumber) {
                      0 => _friendList(context, viewModel, loginUserId),
                      1 => _friendRequest(context, viewModel, loginUserId),
                      2 => _blockList(context, viewModel, loginUserId),
                      int() => throw UnimplementedError(),
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _buildHeader(BuildContext context, FriendViewModel viewModel) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "친구",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.opicBlack,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.person_add_alt_rounded,
                  color: AppColors.opicBlack,
                  size: 20,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.6),
                    builder: (context) => AddFriendPopUp(),
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _tabButton(
                  label: '친구',
                  count: viewModel.friends.length,
                  isSelected: viewModel.tabNumber == 0,
                  onTap: () {
                    viewModel.changeTab(0);
                  },
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _tabButton(
                  label: '요청',
                  count: viewModel.friendRequests.length,
                  isSelected: viewModel.tabNumber == 1,
                  onTap: () {
                    viewModel.changeTab(1);
                  },
                  icon: Icons.mail_outline_rounded,
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _tabButton(
                  label: '차단',
                  count: viewModel.blockUsers.length,
                  isSelected: viewModel.tabNumber == 2,
                  onTap: () {
                    viewModel.changeTab(2);
                  },
                  icon: Icons.block_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// 친구 목록 <-> 친구 요청 탭 버튼
Widget _tabButton({
  required String label,
  required int count,
  required bool isSelected,
  required VoidCallback onTap,
  IconData? icon,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.opicSoftBlue : AppColors.opicWarmGrey,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.opicWhite : AppColors.opicBlack,
            ),
            SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.opicWhite : AppColors.opicBlack,
            ),
          ),
          SizedBox(width: 8),
          if (count != 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.opicWhite.withOpacity(0.3)
                    : AppColors.opicBlack.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.opicWhite : AppColors.opicBlack,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

Widget _friendList(
  BuildContext context,
  FriendViewModel viewModel,
  int loginUserId,
) {
  final friendsCount = viewModel.friends.length;

  if (friendsCount == 0) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(loginUserId),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          color: AppColors.opicBackground,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Text(
              '친구 목록이 비어있습니다',
              style: TextStyle(fontSize: 16, color: AppColors.opicBlack),
            ),
          ),
        ),
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: () => viewModel.refresh(loginUserId),
    child: ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      controller: viewModel.scrollController,
      itemCount: friendsCount,
      itemBuilder: (context, index) {
        final friend = viewModel.friends[index];
        final friendUserId = loginUserId == friend.user1Id
            ? friend.user2Id
            : friend.user1Id;

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
    ),
  );
}

Widget _friendRequest(
  BuildContext context,
  FriendViewModel viewModel,
  int loginUserId,
) {
  final friendRequestsCount = viewModel.friendRequests.length;

  if (friendRequestsCount == 0) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(loginUserId),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          color: AppColors.opicBackground,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Text(
              '새로운 친구 요청이 없습니다',
              style: TextStyle(fontSize: 16, color: AppColors.opicBlack),
            ),
          ),
        ),
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: () => viewModel.refresh(loginUserId),
    child: ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      controller: viewModel.scrollController,
      itemCount: friendRequestsCount,
      itemBuilder: (context, index) {
        final friendRequest = viewModel.friendRequests[index];
        final requestId = friendRequest.id;
        final requesterId = friendRequest.requestId;

        final requesterInfo = viewModel.userInfoCache[requesterId];
        final requesterNickname = requesterInfo?.nickname ?? "알 수 없음";

        return Container(
          color: AppColors.opicBackground,
          child: FriendRequestRow(
            userId: loginUserId,
            requestId: requestId,
            requesterNickname: requesterNickname,
            requesterId: requesterId,
          ),
        );
      },
    ),
  );
}

Widget _blockList(
  BuildContext context,
  FriendViewModel viewModel,
  int loginUserId,
) {
  final blockCount = viewModel.blockUsers.length;

  if (blockCount == 0) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(loginUserId),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          color: AppColors.opicBackground,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Text(
              '차단한 유저가 없습니다',
              style: TextStyle(fontSize: 16, color: AppColors.opicBlack),
            ),
          ),
        ),
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: () => viewModel.refresh(loginUserId),
    child: ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      controller: viewModel.scrollController,
      itemCount: blockCount,
      itemBuilder: (context, index) {
        final block = viewModel.blockUsers[index];
        final blockId = block.id;
        final blockUserId = block.blockedUserId;

        final blockUserInfo = viewModel.userInfoCache[blockUserId];
        final blockUserNickname = blockUserInfo?.nickname ?? "알 수 없음";

        return Container(
          color: AppColors.opicBackground,
          child: BlockInfoRow(
            userId: loginUserId,
            blockId: blockId,
            blockUserId: blockUserId,
            blockUserNickname: blockUserNickname,
          ),
        );
      },
    ),
  );
}

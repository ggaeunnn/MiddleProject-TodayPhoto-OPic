import 'package:flutter/material.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/friend/component/add_friend_pop_up.dart';
import 'package:opicproject/features/friend/component/friend_info_row.dart';
import 'package:opicproject/features/friend/component/friend_request_row.dart';
import 'package:opicproject/features/friend/data/friend_view_model.dart';
import 'package:provider/provider.dart';

class FriendScreen extends StatelessWidget {
  const FriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<FriendViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.loginUserId == null) {
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
                    child: viewModel.showFriendRequests
                        ? _friendRequest()
                        : _friendList(context, viewModel),
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
                  label: '친구 목록',
                  count: viewModel.friends.length,
                  isSelected: !viewModel.showFriendRequests,
                  onTap: () {
                    viewModel.changeTab(false);
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _tabButton(
                  label: '친구 요청',
                  count: 2,
                  isSelected: viewModel.showFriendRequests,
                  onTap: () {
                    viewModel.changeTab(true);
                  },
                  icon: Icons.mail_outline_rounded,
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

@override
/// 친구 목록 화면
Widget _friendList(BuildContext context, FriendViewModel viewModel) {
  final loginUserId = viewModel.loginUserId!;
  final friendsCount = viewModel.friends.length;

  if (friendsCount == 0) {
    return Container(
      color: AppColors.opicBackground,
      child: Center(
        child: Text(
          '친구 목록이 비어있습니다',
          style: TextStyle(fontSize: 16, color: AppColors.opicBlack),
        ),
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: () => viewModel.refresh(loginUserId),
    child: ListView.builder(
      controller: viewModel.scrollController,
      itemCount: friendsCount,
      itemBuilder: (context, index) {
        final friend = viewModel.friends[index];

        return Container(
          color: AppColors.opicBackground,
          child: FriendInfoRow(
            userId: loginUserId == friend.user1Id
                ? friend.user2Id
                : friend.user1Id,
          ),
        );
      },
    ),
  );
}

/// 친구 요청 화면
Widget _friendRequest() {
  final friendRequests = [];

  if (friendRequests.isEmpty) {
    return Container(
      color: AppColors.opicBackground,
      child: Center(
        child: Text(
          '새로운 친구 요청이 없습니다',
          style: TextStyle(fontSize: 16, color: AppColors.opicBlack),
        ),
      ),
    );
  }

  return ListView.builder(
    itemCount: friendRequests.length,
    itemBuilder: (context, index) {
      final friendRequest = friendRequests[index];
      return Container(
        color: AppColors.opicBackground,
        child: FriendRequestRow(userId: 1),
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/friend/data/friend_tab.dart';
import 'package:opicproject/features/friend/ui/component/add_friend_pop_up.dart';
import 'package:opicproject/features/friend/ui/component/friend_tab_button.dart';
import 'package:opicproject/features/friend/viewmodel/friend_view_model.dart';
import 'package:provider/provider.dart';

class FriendScreenHeader extends StatelessWidget {
  const FriendScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
            _buildTitleRow(context),
            Consumer<FriendViewModel>(
              builder: (context, viewModel, child) {
                return Row(
                  children: [
                    Expanded(
                      child: FriendTabButton(
                        label: FriendTab.friends.label,
                        count: viewModel.friendsCount,
                        isSelected:
                            viewModel.tabNumber == FriendTab.friends.index,
                        onTap: () =>
                            viewModel.changeTab(FriendTab.friends.index),
                        icon: FriendTab.friends.icon,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Expanded(
                      child: FriendTabButton(
                        label: FriendTab.requests.label,
                        count: viewModel.requestsCount,
                        isSelected:
                            viewModel.tabNumber == FriendTab.requests.index,
                        onTap: () =>
                            viewModel.changeTab(FriendTab.requests.index),
                        icon: FriendTab.requests.icon,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Expanded(
                      child: FriendTabButton(
                        label: FriendTab.blocked.label,
                        count: viewModel.blocksCount,
                        isSelected:
                            viewModel.tabNumber == FriendTab.blocked.index,
                        onTap: () =>
                            viewModel.changeTab(FriendTab.blocked.index),
                        icon: FriendTab.blocked.icon,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "친구",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              color: AppColors.opicBlack,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.person_add_alt_rounded,
            color: AppColors.opicBlack,
            size: 20.0,
          ),
          onPressed: () => _showAddFriendDialog(context),
        ),
      ],
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => const AddFriendPopUp(),
    );
  }
}

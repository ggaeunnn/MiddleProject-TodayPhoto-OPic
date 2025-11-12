import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/friend/data/friend_view_model.dart';
import 'package:opicproject/features/post/ui/post_detail_page.dart';
import 'package:provider/provider.dart';

class AddFriendPopUp extends StatefulWidget {
  const AddFriendPopUp({super.key});

  @override
  State<AddFriendPopUp> createState() => _AddFriendPopUpState();
}

class _AddFriendPopUpState extends State<AddFriendPopUp> {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.opicWhite,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "친구 추가",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppColors.opicBlack,
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _nicknameController, // controller 추가!
              obscureText: false,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.opicBackground,
                hintText: '친구의 닉네임을 입력하세요',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: AppColors.opicSoftBlue,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: AppColors.opicBackground,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final nickname = _nicknameController.text.trim();
                      if (nickname.isEmpty) {
                        showToast("닉네임을 입력해주세요");
                        return;
                      }

                      final viewModel = context.read<FriendViewModel>();
                      final loginUserId = AuthManager.shared.userInfo?.id ?? 0;

                      // 1. 유저 존재 여부 확인
                      await viewModel.checkIfExist(nickname);

                      if (!viewModel.isExist) {
                        showToast("존재하지 않는 사용자예요");
                        return;
                      }

                      // 2. 해당 유저 정보 가져오기
                      await viewModel.fetchAUserByName(nickname);

                      if (viewModel.certainUser == null) {
                        showToast("사용자 정보를 불러올 수 없어요");
                        return;
                      }

                      final targetUserId = viewModel.certainUser?.id ?? 0;

                      // 3. 자기 자신인지 확인
                      if (targetUserId == loginUserId) {
                        showToast("자기 자신에게는 친구 요청을 보낼 수 없어요");
                        return;
                      }

                      // 4. 이미 친구인지 확인
                      await viewModel.checkIfFriend(loginUserId, targetUserId);

                      if (viewModel.isFriend) {
                        showToast("이미 친구인 사용자예요");
                        return;
                      }

                      // 5. 친구 요청 보내기
                      await viewModel.makeARequest(loginUserId, targetUserId);
                      context.pop();
                      showToast("친구 요청을 보냈어요 💌");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.opicSoftBlue,
                      foregroundColor: AppColors.opicWhite,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "친구 요청",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.opicWhite,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffe8e8dc),
                      foregroundColor: Color(0xfffefefe),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "닫기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff515151),
                      ),
                    ),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/post/ui/post_detail_page.dart';
import 'package:opicproject/features/setting/data/setting_view_model.dart';
import 'package:provider/provider.dart';

class EditNicknamePopUp extends StatefulWidget {
  final int loginUserId;
  final String loginUserNickname;

  const EditNicknamePopUp({
    super.key,
    required this.loginUserId,
    required this.loginUserNickname,
  });

  @override
  State<EditNicknamePopUp> createState() => _EditNicknamePopUpState();
}

class _EditNicknamePopUpState extends State<EditNicknamePopUp> {
  final TextEditingController _nicknameController = TextEditingController();
  String _currentInput = '';

  @override
  void initState() {
    super.initState();
    // 초기값 설정
    _nicknameController.text = widget.loginUserNickname;

    // 실시간 입력 감지
    _nicknameController.addListener(() {
      setState(() {
        _currentInput = _nicknameController.text;
      });
    });
  }

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
              "새로운 닉네임을 입력 한 뒤 변경하기를 눌러주세요",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppColors.opicBlack,
              ),
            ),
            SizedBox(height: 8),
            _buildAlert(_currentInput),
            SizedBox(height: 16),
            TextField(
              controller: _nicknameController,
              obscureText: false,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.opicBackground,
                hintText: '닉네임을 입력하세요',
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
                    color: AppColors.opicWarmGrey,
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
                    // 유효하지 않으면 버튼 비활성화
                    onPressed: _isValidNickname(_currentInput)
                        ? () {
                            // 저장 로직
                            context.read<SettingViewModel>().checkIfExist(
                              _currentInput,
                            );
                            if (context.read<SettingViewModel>().isExist) {
                              showToast("이미 사용 중인 닉네임이에요");
                              return;
                            } else {
                              context.pop();
                              context.read<SettingViewModel>().editNickname(
                                widget.loginUserId,
                                _currentInput,
                              );
                              showToast("닉네임을 변경했어요");
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.opicSoftBlue,
                      foregroundColor: AppColors.opicWhite,
                      disabledBackgroundColor: AppColors.opicWarmGrey,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "변경하기",
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
                      backgroundColor: AppColors.opicWarmGrey,
                      foregroundColor: AppColors.opicWhite,
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

  // 실시간 alert 위젯
  Widget _buildAlert(String nickname) {
    if (nickname.isEmpty) {
      return Text(
        "닉네임을 입력해주세요",
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
          color: AppColors.opicLightBlack,
        ),
      );
    }

    if (nickname.length < 2) {
      return Text(
        "닉네임 길이가 너무 짧아요 (최소 2글자)",
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
          color: AppColors.opicRed,
        ),
      );
    }

    if (nickname.length > 10) {
      return Text(
        "닉네임 길이가 너무 길어요 (10글자 이내)",
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
          color: AppColors.opicRed,
        ),
      );
    }

    // 유효한 경우
    return Text(
      "사용 가능한 닉네임입니다 ✓",
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 11,
        color: AppColors.opicLightBlack,
      ),
    );
  }

  // 닉네임 유효성 검사
  bool _isValidNickname(String nickname) {
    return nickname.isNotEmpty && nickname.length >= 2 && nickname.length <= 10;
  }
}

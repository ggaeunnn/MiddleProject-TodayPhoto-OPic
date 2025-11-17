// edit_nickname_pop_up.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/setting/viewmodel/setting_view_model.dart';
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
  Timer? _debounce;
  bool _isChecking = false;
  bool _isDuplicate = false;
  String _checkMessage = '';

  @override
  void initState() {
    super.initState();
    _nicknameController.text = widget.loginUserNickname;

    _nicknameController.addListener(() {
      setState(() {
        _currentInput = _nicknameController.text;
      });

      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _checkNickname();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _checkNickname() async {
    final nickname = _currentInput.trim();

    if (!_isValidNickname(nickname)) {
      setState(() {
        _isChecking = false;
        _isDuplicate = false;
        _checkMessage = '';
      });
      return;
    }

    if (nickname == widget.loginUserNickname) {
      setState(() {
        _isChecking = false;
        _isDuplicate = false;
        _checkMessage = '현재 닉네임입니다';
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _checkMessage = '확인 중...';
    });

    final viewModel = context.read<SettingViewModel>();
    final isDuplicate = await viewModel.checkIfExist(
      nickname,
      widget.loginUserId,
    );

    if (mounted) {
      setState(() {
        _isChecking = false;
        _isDuplicate = isDuplicate;
        _checkMessage = isDuplicate ? '이미 사용 중인 닉네임이에요' : '사용 가능한 닉네임이에요 ✓';
      });
    }
  }

  Future<void> _saveNickname() async {
    final nickname = _currentInput.trim();

    if (!_isValidNickname(nickname)) {
      showToast('닉네임은 2~10글자여야 해요');
      return;
    }

    if (nickname == widget.loginUserNickname) {
      context.pop();
      return;
    }

    if (_isChecking) {
      showToast('중복 확인 중이에요. 잠시만 기다려주세요');
      return;
    }

    if (_isDuplicate) {
      showToast('이미 사용 중인 닉네임이에요');
      return;
    }

    final viewModel = context.read<SettingViewModel>();
    final finalCheck = await viewModel.checkIfExist(
      nickname,
      widget.loginUserId,
    );

    if (finalCheck) {
      showToast('이미 사용 중인 닉네임이에요');
      return;
    }

    final success = await viewModel.editNickname(widget.loginUserId, nickname);

    if (mounted) {
      if (success) {
        showToast('닉네임을 변경했어요');
        context.pop();
      } else {
        showToast('닉네임 변경에 실패했어요');
      }
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.opicBlue,
      fontSize: 14,
      textColor: AppColors.opicWhite,
      toastLength: Toast.LENGTH_SHORT,
    );
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
              "새로운 닉네임을 입력 한 뒤\n변경하기를 눌러주세요",
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
            Consumer<SettingViewModel>(
              builder: (context, viewModel, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            (_isValidNickname(_currentInput) &&
                                !_isDuplicate &&
                                !_isChecking &&
                                !viewModel.isLoading)
                            ? _saveNickname
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
                        child: viewModel.isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.opicWhite,
                                ),
                              )
                            : Text(
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
                        onPressed: viewModel.isLoading
                            ? null
                            : () => context.pop(),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlert(String nickname) {
    if (_isChecking) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.opicBlue,
            ),
          ),
          SizedBox(width: 8),
          Text(
            _checkMessage,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 11,
              color: AppColors.opicBlue,
            ),
          ),
        ],
      );
    }

    if (_checkMessage.isNotEmpty &&
        nickname != widget.loginUserNickname &&
        _isValidNickname(nickname)) {
      return Text(
        _checkMessage,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
          color: _isDuplicate ? AppColors.opicRed : AppColors.opicBlue,
        ),
      );
    }

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

    if (nickname == widget.loginUserNickname) {
      return Text(
        "현재 닉네임입니다",
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
          color: AppColors.opicLightBlack,
        ),
      );
    }

    return Text(
      "변경하기를 눌러주세요 ✓",
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 11,
        color: AppColors.opicLightBlack,
      ),
    );
  }

  bool _isValidNickname(String nickname) {
    return nickname.isNotEmpty && nickname.length >= 2 && nickname.length <= 10;
  }
}

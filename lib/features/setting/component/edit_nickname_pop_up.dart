import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/component/toast_pop.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/setting/component/nickname_validation_message.dart';
import 'package:opicproject/features/setting/data/nickname_check_state.dart';
import 'package:opicproject/features/setting/utils/nickname_validator.dart';
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

  @override
  void initState() {
    super.initState();
    _nicknameController.text = widget.loginUserNickname;
    _nicknameController.addListener(_onNicknameChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nicknameController.dispose();
    super.dispose();
  }

  void _onNicknameChanged() {
    setState(() {
      _currentInput = _nicknameController.text;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: 500), _checkNickname);
  }

  Future<void> _checkNickname() async {
    final nickname = _currentInput.trim();
    final viewModel = context.read<SettingViewModel>();

    if (!NicknameValidator.isValid(nickname)) {
      viewModel.updateNicknameCheckState(const NicknameCheckState.idle());
      return;
    }

    if (nickname == widget.loginUserNickname) {
      viewModel.updateNicknameCheckState(const NicknameCheckState.current());
      return;
    }

    viewModel.updateNicknameCheckState(const NicknameCheckState.checking());

    final isDuplicate = await viewModel.checkNicknameAvailability(
      nickname,
      widget.loginUserId,
    );
  }

  Future<void> _saveNickname() async {
    final nickname = _currentInput.trim();
    final viewModel = context.read<SettingViewModel>();

    if (!NicknameValidator.isValid(nickname)) {
      ToastPop.show('닉네임은 2~10글자여야 해요');
      return;
    }

    if (nickname == widget.loginUserNickname) {
      context.pop();
      return;
    }

    if (viewModel.nicknameCheckState.isChecking) {
      ToastPop.show('중복 확인 중이에요. 잠시만 기다려주세요');
      return;
    }

    if (viewModel.nicknameCheckState.isDuplicate) {
      ToastPop.show('이미 사용 중인 닉네임이에요');
      return;
    }

    // 최종 중복 확인
    final finalCheck = await viewModel.checkNicknameAvailability(
      nickname,
      widget.loginUserId,
    );

    if (finalCheck) {
      ToastPop.show('이미 사용 중인 닉네임이에요');
      return;
    }

    final success = await viewModel.updateNickname(
      widget.loginUserId,
      nickname,
    );

    if (mounted) {
      if (success) {
        ToastPop.show('닉네임을 변경했어요');
        context.pop();
      } else {
        ToastPop.show('닉네임 변경에 실패했어요');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.opicWhite,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '새로운 닉네임을 입력 한 뒤\n변경하기를 눌러주세요',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
                color: AppColors.opicBlack,
              ),
            ),
            const SizedBox(height: 8),
            Consumer<SettingViewModel>(
              builder: (context, viewModel, child) {
                return NicknameValidationMessage(
                  nickname: _currentInput,
                  currentNickname: widget.loginUserNickname,
                  checkState: viewModel.nicknameCheckState,
                );
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(),
            const SizedBox(height: 24),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _nicknameController,
      obscureText: false,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.opicBackground,
        hintText: '닉네임을 입력하세요',
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: AppColors.opicSoftBlue),
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: AppColors.opicWarmGrey),
          borderRadius: BorderRadius.circular(16),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildButtons() {
    return Consumer<SettingViewModel>(
      builder: (context, viewModel, child) {
        final isValid = NicknameValidator.isValid(_currentInput);
        final canSave =
            isValid &&
            !viewModel.nicknameCheckState.isDuplicate &&
            !viewModel.nicknameCheckState.isChecking &&
            !viewModel.isLoading;

        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: canSave ? _saveNickname : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.opicSoftBlue,
                  foregroundColor: AppColors.opicWhite,
                  disabledBackgroundColor: AppColors.opicWarmGrey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: viewModel.isLoading
                    ? SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: AppColors.opicWhite,
                        ),
                      )
                    : Text(
                        '변경하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.opicWhite,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.opicWarmGrey,
                  foregroundColor: AppColors.opicWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "닫기",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.opicBlack,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/setting/data/nickname_check_state.dart';
import 'package:opicproject/features/setting/utils/nickname_validator.dart';

class NicknameValidationMessage extends StatelessWidget {
  final String nickname;
  final String currentNickname;
  final NicknameCheckState checkState;

  const NicknameValidationMessage({
    super.key,
    required this.nickname,
    required this.currentNickname,
    required this.checkState,
  });

  @override
  Widget build(BuildContext context) {
    // 체크 중
    if (checkState.isChecking) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: AppColors.opicBlue,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            checkState.message,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 11.0,
              color: AppColors.opicBlue,
            ),
          ),
        ],
      );
    }

    // 검증 메시지가 있고, 현재 닉네임이 아니고, 유효한 경우
    if (checkState.message.isNotEmpty &&
        nickname != currentNickname &&
        NicknameValidator.isValid(nickname)) {
      return Text(
        checkState.message,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11.0,
          color: checkState.isDuplicate
              ? AppColors.opicRed
              : AppColors.opicBlue,
        ),
      );
    }

    // 기본 검증 메시지
    final validationMessage = NicknameValidator.getValidationMessage(
      nickname,
      currentNickname: currentNickname,
    );

    if (validationMessage != null) {
      return Text(
        validationMessage,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11.0,
          color: _getValidationMessageColor(nickname),
        ),
      );
    }

    // 변경 가능 상태
    return Text(
      "변경하기를 눌러주세요 ✔",
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 11.0,
        color: AppColors.opicLightBlack,
      ),
    );
  }

  Color _getValidationMessageColor(String nickname) {
    if (nickname.isEmpty || nickname == currentNickname) {
      return AppColors.opicLightBlack;
    }
    if (!NicknameValidator.isValid(nickname)) {
      return AppColors.opicRed;
    }
    return AppColors.opicLightBlack;
  }
}

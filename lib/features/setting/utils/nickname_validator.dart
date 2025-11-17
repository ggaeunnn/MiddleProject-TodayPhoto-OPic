class NicknameValidator {
  static bool isValid(String nickname) {
    return nickname.isNotEmpty && nickname.length >= 2 && nickname.length <= 10;
  }

  static String? getValidationMessage(
    String nickname, {
    required String currentNickname,
  }) {
    if (nickname.isEmpty) {
      return '닉네임을 입력해주세요';
    }

    if (nickname.length < 2) {
      return '닉네임 길이가 너무 짧아요 (최소 2글자)';
    }

    if (nickname.length > 10) {
      return '닉네임 길이가 너무 길어요 (10글자 이내)';
    }

    if (nickname == currentNickname) {
      return '현재 닉네임과 동일해요';
    }

    return null;
  }
}

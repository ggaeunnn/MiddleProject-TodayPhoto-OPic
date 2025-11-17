enum NicknameCheckStatus {
  idle,
  checking,
  available,
  duplicate,
  invalid,
  current,
}

class NicknameCheckState {
  final NicknameCheckStatus status;
  final String message;

  const NicknameCheckState({required this.status, required this.message});

  const NicknameCheckState.idle()
    : status = NicknameCheckStatus.idle,
      message = '';

  const NicknameCheckState.checking()
    : status = NicknameCheckStatus.checking,
      message = '확인 중...';

  const NicknameCheckState.available()
    : status = NicknameCheckStatus.available,
      message = '사용 가능한 닉네임이에요 ✔';

  const NicknameCheckState.duplicate()
    : status = NicknameCheckStatus.duplicate,
      message = '이미 사용 중인 닉네임이에요';

  const NicknameCheckState.current()
    : status = NicknameCheckStatus.current,
      message = '현재 닉네임입니다';

  bool get isValid => status == NicknameCheckStatus.available;
  bool get isChecking => status == NicknameCheckStatus.checking;
  bool get isDuplicate => status == NicknameCheckStatus.duplicate;
}

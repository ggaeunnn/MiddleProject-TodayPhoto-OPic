import 'package:opicproject/core/models/onboarding_model.dart';

class OnboardingDataRepository {
  static const String _onboardingKey = 'hasSeenOnboarding';

  Future<List<Onboarding>> fetchOnboardingData() async {
    //TODO:데이터베이스를 통해 온보딩 이미지들을 가져와야함
    // 2초 지연을 통해 네트워크 통신처럼 잠깐 기다리기
    await Future.delayed(const Duration(seconds: 2));

    //더미데이터
    return [
      Onboarding(
        id: 1,
        imageUrl:
            'https://plus.unsplash.com/premium_photo-1669349127520-fa1e30b02055?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8MXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=500',
        description: '첫번째 온보딩',
        createdAt: DateTime.now().toString(),
        isUse: true,
      ),
      Onboarding(
        id: 2,
        imageUrl:
            'https://plus.unsplash.com/premium_photo-1669349129088-002df7abca61?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8MnxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=500',
        description: '두번째 온보딩',
        createdAt: DateTime.now().toString(),
        isUse: true,
      ),
      Onboarding(
        id: 3,
        imageUrl:
            'https://plus.unsplash.com/premium_photo-1669349127566-9be644ceac6e?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8M3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=500',
        description: '세번째 온보딩',
        createdAt: DateTime.now().toString(),
        isUse: true,
      ),
    ];
  }

  // 온보딩 완료 상태 저장
  Future<void> saveOnboardingCompleted(bool completed) async {
    //TODO:로컬저장을 통해 해당 사용자가 온보딩을 보았다는 상태저장
    /*final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, completed);*/
  }

  // 온보딩 완료 상태 조회
  Future<bool> getOnboardingStatus() async {
    //TODO:로컬저장되어있는 온보딩을 본적있는지 확인
    /*final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;*/
    return false;
  }
}

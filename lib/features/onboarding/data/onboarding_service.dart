import 'package:opicproject/core/models/onboarding_model.dart';
import 'package:opicproject/features/onboarding/data/onboarding_repository.dart';

class OnboardingService {
  final OnboardingDataRepository _dataRepository;

  OnboardingService(this._dataRepository);

  //온보딩 콘텐츠 데이터 가져오기
  Future<List<Onboarding>> loadContents() async {
    return await _dataRepository.fetchOnboardingData();
  }

  //온보딩 완료 상태를 저장
  Future<void> markOnboardingCompleted() async {
    // 비즈니스 로직: true로 설정하고 저장
    await _dataRepository.saveOnboardingCompleted(true);
  }

  //온보딩 상태를 조회
  Future<bool> checkOnboardingStatus() async {
    return await _dataRepository.getOnboardingStatus();
  }
}

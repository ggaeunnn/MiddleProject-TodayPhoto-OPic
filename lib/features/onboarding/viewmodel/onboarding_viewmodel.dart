import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:opicproject/core/models/onboarding_model.dart';
import 'package:opicproject/features/onboarding/data/onboarding_repository.dart';

class OnboardingViewModel extends ChangeNotifier {
  final OnboardingDataRepository _repository =
      GetIt.instance<OnboardingDataRepository>();

  List<Onboarding> _onboardings = [];
  bool _hasSeenOnboarding = false;
  bool _isInitialized = false; // 초기화/로딩 완료 여부
  int _currentPage = 0;

  // ===== Public Getters =====
  List<Onboarding> get onboardings => _onboardings;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isInitialized => _isInitialized; // 뷰는 이 상태가 true일 때 렌더링 시작
  int get currentPage => _currentPage;
  bool get isLastPage => _currentPage == _onboardings.length - 1;

  OnboardingViewModel() {
    _initialize();
  }

  //뷰모델 초기화시에 만약 온보딩을 이전에 봤다면 데이터가져오지않음
  void _initialize() async {
    _hasSeenOnboarding = await _repository.getOnboardingStatus();

    if (!_hasSeenOnboarding) {
      await _fetchOnboardingContents();
    }

    _isInitialized = true;
    notifyListeners();
  }

  // 온보딩 데이터 가져오기
  Future<void> _fetchOnboardingContents() async {
    _onboardings = await _repository.fetchOnboardingData();
  }

  // 현재 페이지 업데이트
  void updatePage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  // 온보딩 완료 처리
  void completeOnboarding() {
    _repository.saveOnboardingCompleted();
    _hasSeenOnboarding = true;
    notifyListeners();
  }
}

import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/core/models/onboarding_model.dart';

class OnboardingDataRepository {
  static const String _onboardingKey = 'hasSeenOnboarding';
  //사용중인 온보딩이미지 가져오기
  Future<List<Onboarding>> fetchOnboardingData() async {
    List<Map<String, dynamic>> data = await SupabaseManager.shared.supabase
        .from('onboarding')
        .select("*")
        .eq('is_use', true)
        .order('order', ascending: true);

    final List<Onboarding> results = data.map((Map<String, dynamic> json) {
      return Onboarding.fromJson(json);
    }).toList();

    return results;
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

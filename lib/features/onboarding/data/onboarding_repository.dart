import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/core/models/onboarding_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Future<void> saveOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_onboardingKey, true);
  }

  // 온보딩 완료 상태 조회
  Future<bool> getOnboardingStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    // 저장된 값이 true면 true, false면 false 반환 저장이 없다면 false반환
    return hasSeenOnboarding;
  }
}

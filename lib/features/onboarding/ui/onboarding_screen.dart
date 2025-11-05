import 'package:flutter/material.dart';
import 'package:opicproject/core/models/onboarding_model.dart';
import 'package:opicproject/features/home/home.dart';
import 'package:opicproject/features/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  //마지막페이지 여부에 따라 진행
  void _handlePageAction(OnboardingViewModel viewModel) {
    if (viewModel.isLastPage) {
      //온보딩 완료상태저장
      viewModel.completeOnboarding();
      //홈화면 이동
      _navigateToHome();
    } else {
      //다음페이지가 있다면 넘어가기
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    }
  }

  // TODO:고라우터 방식으로 변경 필요
  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingViewModel>(
      builder: (context, viewModel, child) {
        //뷰모델상태가 초기화완료상태가아니라면 대기
        if (!viewModel.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        //온보딩이상태가 완료되었다면 홈으로
        if (viewModel.hasSeenOnboarding) {
          // 비동기 초기화 중 상태가 변경되었을 경우, 여기서 즉시 이동
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToHome();
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isLastPage = viewModel.isLastPage;
        final contents = viewModel.onboardings;

        return Scaffold(
          body: _buildOnboardingUI(context, viewModel, isLastPage, contents),
        );
      },
    );
  }

  // 화면 구성 위젯
  Widget _buildOnboardingUI(
    BuildContext context,
    OnboardingViewModel viewModel,
    bool isLastPage,
    List<Onboarding> contents,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8AAAC8), Color(0xFFB1C4DA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: isLastPage
                  ? const SizedBox.shrink()
                  : TextButton(
                      onPressed: () {
                        viewModel.completeOnboarding();
                        _navigateToHome();
                      },
                      child: const Text(
                        '건너뛰기',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: contents.length,
                onPageChanged:
                    viewModel.updatePage, // 페이지 변경 시 ViewModel 상태 업데이트
                itemBuilder: (context, index) {
                  return OnboardingPage(content: contents[index]);
                },
              ),
            ),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    contents.length,
                    (index) => _buildDot(index, context, viewModel.currentPage),
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _handlePageAction(viewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastPage ? '시작하기' : '다음',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isLastPage)
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.black87,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 페이지 인디케이터 (점) 위젯
  Container _buildDot(int index, BuildContext context, int currentPage) {
    return Container(
      height: 8,
      width: currentPage == index ? 24 : 8,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentPage == index ? Colors.white : Colors.white54,
      ),
    );
  }
}

//개별 온보딩페이지
class OnboardingPage extends StatelessWidget {
  final Onboarding content;

  const OnboardingPage({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                content.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;

                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 150),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/models/onboarding_model.dart';
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

  void _handlePageAction(OnboardingViewModel viewModel) {
    if (viewModel.isLastPage) {
      viewModel.completeOnboarding();
      context.go('/home');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.hasSeenOnboarding) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/home');
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

  Widget _buildOnboardingUI(
    BuildContext context,
    OnboardingViewModel viewModel,
    bool isLastPage,
    List<Onboarding> contents,
  ) {
    return Stack(
      children: [
        // 1. 전체 화면 배경 이미지 PageView
        PageView.builder(
          controller: _pageController,
          itemCount: contents.length,
          onPageChanged: viewModel.updatePage,
          itemBuilder: (context, index) {
            return OnboardingPage(content: contents[index]);
          },
        ),

        // 2. 상단 우측 - 건너뛰기 버튼
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          child: SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 24),
                child: isLastPage
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: () {
                          viewModel.completeOnboarding();
                          context.go('/home');
                        },
                        child: const Text(
                          '건너뛰기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black26),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),

        // 3. 하단 - 인디케이터 및 버튼
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 페이지 인디케이터
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                      (index) =>
                          _buildDot(index, context, viewModel.currentPage),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 다음/시작하기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _handlePageAction(viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.opicYellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black38,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastPage ? '시작하기' : '다음',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!isLastPage)
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.opicBlack,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Container _buildDot(int index, BuildContext context, int currentPage) {
    return Container(
      height: 8,
      width: currentPage == index ? 24 : 8,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentPage == index ? Colors.white : Colors.white54,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
    );
  }
}

// 개별 온보딩 페이지 - 전체 화면 이미지
class OnboardingPage extends StatelessWidget {
  final Onboarding content;

  const OnboardingPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.network(
        content.imageUrl,
        fit: BoxFit.cover, // 전체 화면을 꽉 채움
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFF8AAAC8),
            child: const Center(
              child: Icon(Icons.error_outline, color: Colors.white, size: 50),
            ),
          );
        },
      ),
    );
  }
}

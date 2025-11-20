import 'package:flutter/material.dart';

class PageCountViewmodel extends ChangeNotifier {
  int currentPage = 0;
  final PageController pageController = PageController();

  void increment() {
    if (currentPage != -1 || currentPage != 5) {
      currentPage++;
      notifyListeners(); // 값 증가 후 상태 변경 알림
    }
  }

  void decrement() {
    if (currentPage != -1 || currentPage != 5) {
      currentPage--;
      notifyListeners(); // 값 감소 후 상태 변경 알림
    }
  }

  void onPageChanged(int index) {
    currentPage = index;
    pageController.animateToPage(
      currentPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }
}

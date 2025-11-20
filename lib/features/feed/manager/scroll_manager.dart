import 'dart:async';

import 'package:flutter/material.dart';

class ScrollManager {
  final ScrollController controller;
  final VoidCallback onScrollToBottom;
  final ValueChanged<bool> onScrollButtonVisibilityChanged;

  Timer? _debounce;
  bool _isLoadingMore = false;

  ScrollManager({
    required this.controller,
    required this.onScrollToBottom,
    required this.onScrollButtonVisibilityChanged,
  });

  void initialize() {
    controller.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(
      const Duration(milliseconds: 300),
      _updateScrollButtonVisibility,
    );

    if (_isScrollNearBottom() && !_isLoadingMore) {
      debugPrint('Scroll End');
      _isLoadingMore = true;
      onScrollToBottom();
    }
  }

  void _updateScrollButtonVisibility() {
    final double offset = controller.offset;
    final bool shouldShow = offset >= 60.0;
    onScrollButtonVisibilityChanged(shouldShow);
  }

  bool _isScrollNearBottom() {
    if (!controller.hasClients) return false;

    final position = controller.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;

    const bottomThreshold = 200.0;

    return currentScroll >= (maxScroll - bottomThreshold);
  }

  // 로딩 완료 시 플래그 리셋
  void resetLoadingState() {
    _isLoadingMore = false;
  }

  void scrollToTop() {
    controller.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  void dispose() {
    _debounce?.cancel();
    controller.removeListener(_handleScroll);
  }
}

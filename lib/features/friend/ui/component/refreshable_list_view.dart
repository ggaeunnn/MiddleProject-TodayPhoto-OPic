import 'package:flutter/material.dart';
import 'package:opicproject/features/friend/ui/component/empty_state_view.dart';

class RefreshableListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Future<void> Function() onRefresh;
  final ScrollController controller;
  final String emptyMessage;

  const RefreshableListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onRefresh,
    required this.controller,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return EmptyStateView(message: emptyMessage, onRefresh: onRefresh);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: controller,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}

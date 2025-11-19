import 'package:flutter/material.dart';
import 'package:opicproject/core/app_colors.dart';

class FeedEmptyState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRefresh;

  const FeedEmptyState({
    super.key,
    required this.message,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          color: AppColors.opicBackground,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Text(
              message,
              style: TextStyle(fontSize: 16, color: AppColors.opicBlack),
            ),
          ),
        ),
      ),
    );
  }
}

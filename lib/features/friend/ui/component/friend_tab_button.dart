import 'package:flutter/material.dart';
import 'package:opicproject/core/app_colors.dart';

class FriendTabButton extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const FriendTabButton({
    super.key,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.opicSoftBlue : AppColors.opicWarmGrey,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20.0,
                color: isSelected ? AppColors.opicWhite : AppColors.opicBlack,
              ),
              const SizedBox(width: 8.0),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.opicWhite : AppColors.opicBlack,
              ),
            ),
            const SizedBox(width: 8.0),
            if (count != 0) _buildCountBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildCountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.opicWhite.withOpacity(0.3)
            : AppColors.opicBlack.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.opicWhite : AppColors.opicBlack,
        ),
      ),
    );
  }
}

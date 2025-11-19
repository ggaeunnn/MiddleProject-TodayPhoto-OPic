import 'package:flutter/material.dart';
import 'package:opicproject/core/app_colors.dart';

class MenuOption {
  final IconData icon;
  final String text;
  final Color? color;
  final VoidCallback onTap;

  MenuOption({
    required this.icon,
    required this.text,
    required this.onTap,
    this.color,
  });
}

class EditMenu extends StatelessWidget {
  final List<MenuOption> options;

  const EditMenu({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.opicBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.opicCoolGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            ...options.map(
              (option) => _buildMenuItem(
                context: context,
                icon: option.icon,
                text: option.text,
                color: option.color,
                onTap: option.onTap,
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color ?? AppColors.opicBlack),
            SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color ?? AppColors.opicBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

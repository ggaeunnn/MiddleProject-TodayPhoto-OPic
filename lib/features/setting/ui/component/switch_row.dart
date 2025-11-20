import 'package:flutter/material.dart';
import 'package:opicproject/core/app_colors.dart';

class SwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool)? onChanged;
  final Color circleColor = AppColors.opicWhite;
  final Color backgroundColor = AppColors.opicSoftBlue;
  final Color inactiveCircleColor = AppColors.opicWhite;
  final Color inactiveBackgroundColor = AppColors.opicCoolGrey;

  SwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(fontSize: 15, color: AppColors.opicBlack)),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: circleColor,
            activeTrackColor: backgroundColor,
            inactiveThumbColor: inactiveCircleColor,
            inactiveTrackColor: inactiveBackgroundColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
      ],
    );
  }
}

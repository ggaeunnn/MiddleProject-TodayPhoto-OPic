import 'package:flutter/material.dart';

class SwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool) onChanged;
  final Color circleColor = Color(0xfffafafa);
  final Color backgroundColor = Color(0xff95b7db);
  final Color inactiveCircleColor = Color(0xfffafafa);
  final Color inactiveBackgroundColor = Color(0xffe8e8dc);

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
        Text(title, style: TextStyle(fontSize: 15, color: Color(0xff515151))),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: circleColor,
            activeTrackColor: backgroundColor,
            inactiveThumbColor: inactiveCircleColor,
            inactiveTrackColor: inactiveBackgroundColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ),
      ],
    );
  }
}

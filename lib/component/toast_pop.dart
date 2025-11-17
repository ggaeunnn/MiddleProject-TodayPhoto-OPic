import 'package:fluttertoast/fluttertoast.dart';
import 'package:opicproject/core/app_colors.dart';

class ToastPop {
  static void show(String message) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.opicBlue,
      fontSize: 14.0,
      textColor: AppColors.opicWhite,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}

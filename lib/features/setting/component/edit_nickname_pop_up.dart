import 'package:flutter/material.dart';

class EditNicknamePopUp extends StatelessWidget {
  final String currentNickname;

  const EditNicknamePopUp({super.key, required this.currentNickname});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Color(0xfffefefe),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "새로운 닉네임을 입력 한 뒤 저장을 눌러주세요",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xff515151),
              ),
            ),
            SizedBox(height: 24),
            TextField(
              obscureText: false,
              decoration: InputDecoration(
                labelText: '닉네임',
                hintText: '닉네임을 입력하세요',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Color(0xff95b7db)),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Color(0xffe8e8dc)),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff95b7db),
                      foregroundColor: Color(0xfffefefe),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "저장하기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xfffefefe),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffe8e8dc),
                      foregroundColor: Color(0xfffefefe),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "닫기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff515151),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

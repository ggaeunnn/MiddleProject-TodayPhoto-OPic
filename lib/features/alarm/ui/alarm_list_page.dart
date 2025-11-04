import 'package:flutter/material.dart';

class AlarmListPage extends StatelessWidget {
  final int userId;
  const AlarmListPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return const Placeholder(child: _AlarmListPage());
  }
}

class _AlarmListPage extends StatefulWidget {
  const _AlarmListPage({super.key});

  @override
  State<_AlarmListPage> createState() => _AlarmListPageState();
}

class _AlarmListPageState extends State<_AlarmListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xfffafafa),
                border: Border(
                  bottom: BorderSide(color: Color(0xff95b7db), width: 0.5),
                ),
              ),
              width: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 10.0,
                ),
                child: Row(
                  spacing: 10,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xff515151),
                      ),
                      onPressed: () {},
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                    ),
                    Text(
                      "알림",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xff515151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Color(0xfffcfcf0),
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("ListView 들어갈 자리. 내용물은 Component로 뽑아야할 것 같습니다"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

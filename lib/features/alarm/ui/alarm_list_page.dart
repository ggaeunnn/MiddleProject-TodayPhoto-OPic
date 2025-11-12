import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/alarm/component/alarm_row.dart';
import 'package:opicproject/features/alarm/data/alarm_view_model.dart';
import 'package:provider/provider.dart';

class AlarmListScreen extends StatelessWidget {
  final int userId;
  const AlarmListScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return const Placeholder(child: _AlarmListScreen());
  }
}

class _AlarmListScreen extends StatefulWidget {
  const _AlarmListScreen();

  @override
  State<_AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<_AlarmListScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<AlarmViewModel>();
    final loginUserId = AuthManager.shared.userInfo?.id ?? 0;
    viewModel.fetchAlarms(1, loginUserId);
    final alarmList = viewModel.alarms;

    return Scaffold(
      backgroundColor: AppColors.opicWhite,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: AppColors.opicWhite,
                border: Border(
                  top: BorderSide(color: AppColors.opicSoftBlue, width: 0.5),
                  bottom: BorderSide(color: AppColors.opicSoftBlue, width: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 5.0,
                ),
                child: Row(
                  spacing: 10,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.opicBlack,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
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
                        color: AppColors.opicBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: AppColors.opicBackground,
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: alarmList.isEmpty
                      ? Container(
                          color: AppColors.opicBackground,
                          child: Center(
                            child: Text(
                              '새로운 알림이 없습니다',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.opicBlack,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: alarmList.length,
                          itemBuilder: (context, index) {
                            final alarm = alarmList[index];
                            return Container(
                              child: AlarmRow(alarmId: alarmList[index].id),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

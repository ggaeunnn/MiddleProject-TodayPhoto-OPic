import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/models/alarm_model.dart';
import 'package:opicproject/features/alarm/component/alarm_row.dart';
import 'package:opicproject/features/alarm/data/alarm_view_model.dart';
import 'package:provider/provider.dart';

class AlarmListScreen extends StatelessWidget {
  final int userId;
  const AlarmListScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Placeholder(child: _AlarmListScreen(userId: userId));
  }
}

class _AlarmListScreen extends StatefulWidget {
  final int userId;
  const _AlarmListScreen({required this.userId});

  @override
  State<_AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<_AlarmListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<AlarmViewModel>();
      final loginUserId = AuthManager.shared.userInfo?.id;
      if (loginUserId != null && !viewModel.isInitialized) {
        viewModel.initialize(loginUserId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.opicWhite,
      body: SafeArea(
        child: Consumer<AlarmViewModel>(
          builder: (context, viewModel, child) {
            final loginUserId = AuthManager.shared.userInfo?.id;

            if (loginUserId == null) {
              return Container(
                decoration: BoxDecoration(color: AppColors.opicBackground),
                child: Center(child: Text("로그인 해주세요")),
              );
            }

            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Container(
                    color: AppColors.opicBackground,
                    child: viewModel.isLoading && viewModel.alarms.isEmpty
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.opicBlue,
                            ),
                          )
                        : _buildAlarmList(context, viewModel, loginUserId),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _buildHeader(BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      color: AppColors.opicWhite,
      border: Border(
        top: BorderSide(color: AppColors.opicSoftBlue, width: 0.5),
        bottom: BorderSide(color: AppColors.opicSoftBlue, width: 0.5),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Row(
        spacing: 10,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppColors.opicBlack),
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
  );
}

Widget _buildAlarmList(
  BuildContext context,
  AlarmViewModel viewModel,
  int loginUserId,
) {
  final alarmList = viewModel.alarms;
  final alarmCount = alarmList.length;

  // 알림이 없을 때
  if (alarmCount == 0) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(loginUserId),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          color: AppColors.opicBackground,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Text(
              '새로운 알림이 없습니다',
              style: TextStyle(fontSize: 16, color: AppColors.opicBlack),
            ),
          ),
        ),
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: () => viewModel.refresh(loginUserId),
    child: ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      controller: viewModel.scrollController,
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: alarmCount,
      itemBuilder: (context, index) {
        final alarm = alarmList[index];

        return FutureBuilder<Alarm?>(
          key: ValueKey('alarm_${alarm.id}_$index'),
          future: viewModel
              .fetchAnAlarm(alarm.id)
              .then((_) => viewModel.certainAlarm),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                color: AppColors.opicBackground,
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.opicBlue),
                ),
              );
            }

            return Container(
              color: AppColors.opicBackground,
              child: AlarmRow(alarmId: alarm.id, loginUserId: loginUserId),
            );
          },
        );
      },
    ),
  );
}

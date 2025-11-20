import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/alarm/ui/component/alarm_row.dart';
import 'package:opicproject/features/alarm/viewmodel/alarm_view_model.dart';
import 'package:provider/provider.dart';

class AlarmListScreen extends StatelessWidget {
  const AlarmListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AlarmListScreen();
  }
}

class _AlarmListScreen extends StatefulWidget {
  const _AlarmListScreen();

  @override
  State<_AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<_AlarmListScreen> {
  // 시작시 초기 설정
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<AlarmViewModel>();
      final authManager = context.read<AuthManager>();
      final loginUserId = authManager.userInfo?.id ?? 0;

      if (loginUserId != 0 &&
          viewModel.alarms.isEmpty &&
          !viewModel.isLoading) {
        viewModel.fetchAlarms(1, loginUserId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.opicWhite,
      body: SafeArea(
        child: Consumer2<AlarmViewModel, AuthManager>(
          builder: (context, viewModel, authManager, child) {
            final loginUserId = authManager.userInfo?.id;

            // 로그인이 안되어있는데 접근되었을 경우
            if (loginUserId == null) {
              return Container(
                decoration: BoxDecoration(color: AppColors.opicBackground),
                child: const Center(child: Text("로그인 해주세요")),
              );
            }

            // 로그인 한 뒤 접근했을 경우
            return Stack(
              children: [
                Column(
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
                ),
                // ⭐ 맨 위로 버튼
                if (viewModel.shouldShowScrollUpButton)
                  Positioned(
                    right: 16.0,
                    bottom: 80.0, // 하단 네비게이션바 위
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: AppColors.opicSoftBlue,
                      onPressed: () => viewModel.moveScrollUp(),
                      child: Icon(
                        Icons.arrow_upward,
                        color: AppColors.opicWhite,
                        size: 20.0,
                      ),
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
          // 뒤로가기 버튼 -> 알림 화면을 끄나, 혹시 오류가 날 경우 홈 화면으로 이동함
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppColors.opicBlack),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
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
  if (alarmCount == 0 && !viewModel.isLoading) {
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
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: alarmCount,
      itemBuilder: (context, index) {
        if (index == alarmCount) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.opicBlue,
                strokeWidth: 2.0,
              ),
            ),
          );
        }

        final alarm = alarmList[index];

        return Container(
          color: AppColors.opicBackground,
          child: AlarmRow(alarmId: alarm.id, loginUserId: loginUserId),
        );
      },
    ),
  );
}

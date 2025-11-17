import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/setting/component/switch_row.dart';
import 'package:opicproject/features/setting/data/alarm_state.dart';
import 'package:opicproject/features/setting/viewmodel/setting_view_model.dart';
import 'package:provider/provider.dart';

class SettingAlarmScreen extends StatefulWidget {
  const SettingAlarmScreen({super.key});

  @override
  State<SettingAlarmScreen> createState() => _SettingAlarmScreenState();
}

class _SettingAlarmScreenState extends State<SettingAlarmScreen> {
  AlarmState _alarmState = const AlarmState.initial();
  bool _isInitialized = false;
  bool _isSaving = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadAlarmSettings();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // 푸시 알림 설정 불러오기
  Future<void> _loadAlarmSettings() async {
    final authManager = context.read<AuthManager>();
    final loginUserId = authManager.userInfo?.id ?? 0;
    final viewModel = context.read<SettingViewModel>();

    if (viewModel.alarmSetting == null) {
      await viewModel.fetchAlarmSetting(loginUserId);
    }

    final alarmSetting = viewModel.alarmSetting;

    if (alarmSetting != null && mounted) {
      setState(() {
        _alarmState = AlarmState.fromAlarmSetting(alarmSetting);
        _isInitialized = true;
      });
    }
  }

  // 푸시 알림 설정 저장하기
  Future<void> _saveAlarmSettings() async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (_isSaving || !mounted) return;

      final authManager = context.read<AuthManager>();
      final loginUserId = authManager.userInfo?.id ?? 0;

      setState(() => _isSaving = true);

      final viewModel = context.read<SettingViewModel>();
      final newSetting = _alarmState.toAlarmSetting(loginUserId);

      await viewModel.updateAlarmSetting(
        userId: loginUserId,
        newSetting: newSetting,
      );

      if (mounted) {
        setState(() => _isSaving = false);
      }
    });
  }

  // 전체 알람 변경
  void _onEntireAlarmChanged(bool value) {
    setState(() {
      _alarmState = _alarmState.updateEntireAlarm(value);
    });
    _saveAlarmSettings();
  }

  // 개별 알람 변경
  void _onIndividualAlarmChanged(String type, bool value) {
    setState(() {
      _alarmState = _alarmState.updateIndividual(type, value);
    });
    _saveAlarmSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.opicWhite,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isInitialized
                      ? _buildAlarmSettings()
                      : _buildLoadingView(),
                ),
              ],
            ),
            if (_isSaving || _debounceTimer?.isActive == true)
              _buildSavingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.opicWhite,
        border: Border(
          top: BorderSide(color: AppColors.opicSoftBlue, width: 0.5),
          bottom: BorderSide(color: AppColors.opicSoftBlue, width: 0.5),
        ),
      ),
      width: double.maxFinite,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          spacing: 10,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppColors.opicBlack),
              onPressed: () {
                context.pop();
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
            ),
            Text(
              "푸시 알림 설정",
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

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: AppColors.opicSoftBlue, width: 0.3),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        child: SwitchRow(title: title, value: value, onChanged: onChanged),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(child: CircularProgressIndicator(color: AppColors.opicBlue));
  }

  Widget _buildAlarmSettings() {
    return Container(
      color: AppColors.opicBackground,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: AppColors.opicWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.opicSoftBlue, width: 0.7),
            ),
            child: Column(
              spacing: 5,
              children: [
                _buildSwitchItem(
                  title: '전체 알람',
                  value: _alarmState.entireAlarm,
                  onChanged: _onEntireAlarmChanged,
                ),
                _buildSwitchItem(
                  title: '새로운 주제',
                  value: _alarmState.newTopic,
                  onChanged: (v) => _onIndividualAlarmChanged('newTopic', v),
                ),
                _buildSwitchItem(
                  title: '좋아요',
                  value: _alarmState.likePost,
                  onChanged: (v) => _onIndividualAlarmChanged('likePost', v),
                ),
                _buildSwitchItem(
                  title: '댓글',
                  value: _alarmState.newComment,
                  onChanged: (v) => _onIndividualAlarmChanged('newComment', v),
                ),
                _buildSwitchItem(
                  title: '친구 요청 도착',
                  value: _alarmState.newRequest,
                  onChanged: (v) => _onIndividualAlarmChanged('newRequest', v),
                ),
                _buildSwitchItem(
                  title: '친구 요청 수락',
                  value: _alarmState.newFriend,
                  onChanged: (v) => _onIndividualAlarmChanged('newFriend', v),
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingIndicator() {
    return Positioned(
      top: 60,
      right: 20,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.opicBlack.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.opicWhite),
              ),
            ),
            SizedBox(width: 8),
            Text(
              _isSaving ? '저장 중...' : '대기 중...',
              style: TextStyle(color: AppColors.opicWhite, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

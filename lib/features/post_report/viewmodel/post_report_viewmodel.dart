import 'package:flutter/material.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/features/post/ui/post_detail_page.dart';

class PostReportViewmodel extends ChangeNotifier {
  final TextEditingController reasonController = TextEditingController();

  Future<void> submitReport(int postId, BuildContext context) async {
    final reason = reasonController.text;

    if (reason.isEmpty) {
      showToast('신고 사유를 입력해주세요.');
      return;
    }

    final userId = AuthManager.shared.userInfo?.id ?? 0;

    try {
      await SupabaseManager.shared.supabase.from('post_report').insert({
        'reported_post_id': postId,
        'reporter_id': userId,
        'report_reason': reason,
        'checked_at': DateTime.now().toIso8601String(),
        'is_checked': false,
      });

      showToast('신고가 접수되었습니다.');
      Navigator.pop(context);
    } catch (error) {
      print('신고 에러 상세: $error');
      showToast('신고 실패');
    }
  }
}

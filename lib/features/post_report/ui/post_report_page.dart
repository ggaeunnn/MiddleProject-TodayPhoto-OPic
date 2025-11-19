import 'package:flutter/material.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/features/post/ui/post_detail_page.dart';

class PostReportScreen extends StatefulWidget {
  final int postId;
  const PostReportScreen({super.key, required this.postId});

  @override
  _PostReportScreenState createState() => _PostReportScreenState();
}

class _PostReportScreenState extends State<PostReportScreen> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitReport() async {
    final reason = _reasonController.text.trim();

    if (reason.isEmpty) {
      showToast("신고 사유를 입력해주세요.");
      return;
    }

    final userId = AuthManager.shared.userInfo?.id ?? 0;

    setState(() => _isLoading = true);

    try {
      await SupabaseManager.shared.supabase.from('post_report').insert({
        'reported_post_id': widget.postId,
        'reporter_id': userId,
        'report_reason': reason,
        'checked_at': DateTime.now().toIso8601String(),
        'is_checked': false,
      });

      showToast("신고가 접수되었습니다.");
      Navigator.pop(context);
    } catch (e) {
      showToast("신고 실패");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xfffefefe),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("신고하기", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Text(
                    "신고 사유를 입력해주세요",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xff515151),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 입력창
            Container(
              padding: const EdgeInsets.only(left: 15),
              color: const Color(0xFFFCFCF0),
              height: 150,
              child: TextField(
                controller: _reasonController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: '신고 사유를 자세히 작성해주세요...',
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 버튼 2개
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff95b7db),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "신고하기",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xfffefefe),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffe8e8dc),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
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

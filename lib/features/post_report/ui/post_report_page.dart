import 'package:flutter/material.dart';
import 'package:opicproject/features/post_report/viewmodel/post_report_viewmodel.dart';

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
    setState(() => _isLoading = true);
  }

  @override
  Widget build(BuildContext context) {
    final PostReportViewmodel viewmodel = PostReportViewmodel();

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
                controller: viewmodel.reasonController,
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
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() => _isLoading = true);
                            await viewmodel.submitReport(
                              widget.postId,
                              context,
                            );
                            setState(() => _isLoading = false);
                          },
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

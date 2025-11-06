class PostReport {
  final int id;
  final String createdAt;
  final int reportedPostId;
  final int reporterId;
  final String reportReason;
  final String? checkedAt;
  final bool isChecked;

  PostReport({
    required this.id,
    required this.createdAt,
    required this.reportedPostId,
    required this.reporterId,
    required this.reportReason,
    required this.checkedAt,
    required this.isChecked,
  });

  factory PostReport.fromJson(Map<String, dynamic> json) {
    return PostReport(
      id: json['id'] as int,
      createdAt: json['created_at'] as String,
      reportedPostId: json['reported_post_id'] as int,
      reporterId: json['reporter_id'] as int,
      reportReason: json['report_reason'] as String,
      checkedAt: json['checked_at'] as String?,
      isChecked: json['is_checked'] as bool,
    );
  }
}

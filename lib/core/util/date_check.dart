class TimeAgoUtil {
  static String getTimeAgo(String timestampzString) {
    DateTime timestamp = DateTime.parse(timestampzString);
    timestamp = timestamp.toLocal();

    final DateTime now = DateTime.now();

    final Duration difference = now.difference(timestamp);

    if (difference.inDays >= 7) {
      // 7일 이상이면 날짜로 표시
      return '${timestamp.year}.${timestamp.month.toString().padLeft(2, '0')}.${timestamp.day.toString().padLeft(2, '0')}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}

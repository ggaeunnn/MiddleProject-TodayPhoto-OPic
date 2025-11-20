class PostChangeEvent {
  PostEventType type; // 메세지 타입 - 성공, 에러
  // 이벤트 메세지
  String message;
  // 기본값은 성공 타입으로 정하기
  dynamic data;
  PostChangeEvent(this.message, this.type, {this.data});
}

// 이벤트 타입 나누기 - 에러, 성공
enum PostEventType { insert, update, delete, topicChange }

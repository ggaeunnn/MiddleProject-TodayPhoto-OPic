import 'package:flutter/cupertino.dart';

class Onboarding {
  final int id;
  final String imageUrl;
  final String description;
  final String createdAt;
  final bool isUse;

  Onboarding({
    required this.id,
    required this.imageUrl,
    required this.description,
    required this.createdAt,
    required this.isUse,
  });

  factory Onboarding.fromJson(Map<String, dynamic> json) {
    return Onboarding(
      //topicId: json['topic_id'] as int,
      id: json['id'] as int,
      imageUrl: json['image_url'] as String,
      description: json['description'] as String,
      createdAt: json['created_at'] as String,
      isUse: json['is_use'] as bool,
    );
  }
}

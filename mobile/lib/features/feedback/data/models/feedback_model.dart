import '../../domain/entities/feedback.dart';

class FeedbackModel extends UserFeedback {
  const FeedbackModel({
    required super.id,
    required super.rating,
    required super.topic,
    required super.content,
    required super.pageUrl,
    required super.isVisible,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      topic: FeedbackTopic.fromValue((json['topic'] as num?)?.toInt() ?? 0),
      content: json['content'] as String? ?? '',
      pageUrl: json['pageUrl'] as String? ?? '',
      isVisible: json['isVisible'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

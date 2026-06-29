import '../../domain/entities/notification.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.description,
    required super.timestamp,
    required super.iconType,
    required super.category,
    required super.isRead,
    super.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['message'] as String, // Ánh xạ message -> description
      timestamp: json['createdAt'] as String, // Ánh xạ createdAt -> timestamp
      iconType:
          json['iconType'] as String? ??
          'info', // Thêm giá trị mặc định nếu null
      category:
          json['category'] as String? ??
          'general', // Thêm giá trị mặc định nếu null
      isRead:
          json['isRead'] as bool? ?? false, // Thêm giá trị mặc định nếu null
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'timestamp': timestamp,
    'iconType': iconType,
    'category': category,
    'isRead': isRead,
    'metadata': metadata,
  };
}

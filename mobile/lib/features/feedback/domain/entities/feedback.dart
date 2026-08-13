enum FeedbackTopic {
  general(0, 'Trải nghiệm chung'),
  bookingOrder(1, 'Đặt tủ / đơn hàng'),
  payment(2, 'Thanh toán'),
  delivery(3, 'Giao nhận'),
  interface(4, 'Giao diện'),
  other(5, 'Khác');

  const FeedbackTopic(this.value, this.label);

  final int value;
  final String label;

  static FeedbackTopic fromValue(int value) {
    return FeedbackTopic.values.firstWhere(
      (topic) => topic.value == value,
      orElse: () => FeedbackTopic.general,
    );
  }
}

class UserFeedback {
  const UserFeedback({
    required this.id,
    required this.rating,
    required this.topic,
    required this.content,
    required this.pageUrl,
    required this.isVisible,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final int rating;
  final FeedbackTopic topic;
  final String content;
  final String pageUrl;
  final bool isVisible;
  final DateTime createdAt;
  final DateTime updatedAt;
}

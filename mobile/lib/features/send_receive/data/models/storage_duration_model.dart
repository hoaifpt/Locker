import '../../domain/entities/storage_duration.dart';

class StorageDurationModel extends StorageDuration {
  const StorageDurationModel({
    required super.id,
    required super.label,
    required super.durationHours,
    super.isRecommended,
  });

  factory StorageDurationModel.fromJson(Map<String, dynamic> json) {
    return StorageDurationModel(
      id: json['id'] as String,
      label: json['label'] as String,
      durationHours: json['durationHours'] as int,
      isRecommended: json['isRecommended'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'durationHours': durationHours,
      'isRecommended': isRecommended,
    };
  }
}

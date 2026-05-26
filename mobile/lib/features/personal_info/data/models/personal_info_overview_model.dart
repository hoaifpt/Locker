import '../../domain/entities/personal_info_action.dart';
import '../../domain/entities/personal_info_data.dart';
import '../../domain/entities/personal_info_item.dart';
import '../../domain/entities/personal_info_overview.dart';

class PersonalInfoOverviewModel extends PersonalInfoOverview {
  PersonalInfoOverviewModel({
    required super.data,
    required super.items,
    required super.actions,
  });

  factory PersonalInfoOverviewModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final items = (json['items'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(
          (item) => PersonalInfoItem(
            label: item['label'] as String,
            value: item['value'] as String,
            hint: item['hint'] as String,
            isEditable: item['isEditable'] as bool? ?? true,
          ),
        )
        .toList(growable: false);

    final actions = (json['actions'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(
          (action) => PersonalInfoAction(
            title: action['title'] as String,
            subtitle: action['subtitle'] as String,
            route: action['route'] as String,
          ),
        )
        .toList(growable: false);

    return PersonalInfoOverviewModel(
      data: PersonalInfoData(
        fullName: data['fullName'] as String,
        phoneNumber: data['phoneNumber'] as String,
        email: data['email'] as String,
        address: data['address'] as String,
        birthday: data['birthday'] as String,
        membershipTier: data['membershipTier'] as String,
        avatarUrl: data['avatarUrl'] as String,
      ),
      items: items,
      actions: actions,
    );
  }
}
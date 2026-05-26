import 'personal_info_action.dart';
import 'personal_info_data.dart';
import 'personal_info_item.dart';

class PersonalInfoOverview {
  final PersonalInfoData data;
  final List<PersonalInfoItem> items;
  final List<PersonalInfoAction> actions;

  const PersonalInfoOverview({
    required this.data,
    required this.items,
    required this.actions,
  });
}
import 'security_privacy_action.dart';
import 'security_privacy_data.dart';
import 'security_privacy_item.dart';

class SecurityPrivacyOverview {
  final SecurityPrivacyData data;
  final List<SecurityPrivacyItem> settings;
  final List<SecurityPrivacyAction> actions;

  const SecurityPrivacyOverview({
    required this.data,
    required this.settings,
    required this.actions,
  });
}

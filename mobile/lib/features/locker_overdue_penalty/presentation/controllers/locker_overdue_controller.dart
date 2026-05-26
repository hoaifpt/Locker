import 'package:flutter/foundation.dart';
import '../../domain/entities/locker_overdue_info.dart';
import '../../domain/repositories/i_locker_overdue_repository.dart';

class LockerOverdueController extends ChangeNotifier {
  final ILockerOverdueRepository repository;

  LockerOverdueInfo? info;
  bool loading = false;
  String? error;

  LockerOverdueController(this.repository);

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      info = await repository.fetchOverdueInfo();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/locker_detail_repository.dart';
import '../../domain/usecases/get_locker_detail_usecase.dart';
import '../../domain/usecases/open_locker_detail_usecase.dart';
import '../../domain/usecases/update_auto_lock_usecase.dart';
import '../../domain/usecases/update_intrusion_alert_usecase.dart';
import '../controllers/locker_detail_cubit.dart';
import '../locker_detail_screen.dart';

/// Page = BlocProvider wrapper + DI wiring, không chứa logic UI.
/// Nhận [lockerId] qua constructor — truyền từ route arguments.
class LockerDetailPage extends StatelessWidget {
  final String lockerId;
  const LockerDetailPage({super.key, required this.lockerId});

  @override
  Widget build(BuildContext context) {
    final repo = LockerDetailRepository();
    return BlocProvider(
      create: (_) => LockerDetailCubit(
        lockerId: lockerId,
        getDetail: GetLockerDetailUsecase(repo),
        openLocker: OpenLockerDetailUsecase(repo),
        updateAutoLock: UpdateAutoLockUsecase(repo),
        updateIntrusionAlert: UpdateIntrusionAlertUsecase(repo),
      )..load(),
      child: const LockerDetailScreen(),
    );
  }
}

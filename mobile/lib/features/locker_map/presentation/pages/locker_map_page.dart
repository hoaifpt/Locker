import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/locker_map_repository.dart';
import '../../domain/usecases/get_locker_slots_usecase.dart';
import '../../domain/usecases/open_locker_usecase.dart';
import '../controllers/locker_map_cubit.dart';
import '../locker_map_screen.dart';

/// Page = BlocProvider wrapper + DI wiring, không chứa logic UI
class LockerMapPage extends StatelessWidget {
  const LockerMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = LockerMapRepository();
    return BlocProvider(
      create: (_) => LockerMapCubit(
        getLockerSlots: GetLockerSlotsUsecase(repo),
        openLocker: OpenLockerUsecase(repo),
      )..load(),
      child: const LockerMapScreen(),
    );
  }
}

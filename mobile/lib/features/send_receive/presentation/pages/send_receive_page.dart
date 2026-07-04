import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../locker/data/locker_repository.dart';
import '../../../locker/domain/usecases/get_available_lockers_usecase.dart';
import '../../data/send_receive_repository.dart';
import '../../domain/usecases/create_send_receive_order_usecase.dart';
import '../../domain/usecases/get_available_locker_sizes_usecase.dart';
import '../../domain/usecases/get_storage_durations_usecase.dart';
import '../controllers/send_receive_cubit.dart';
import '../send_receive_screen.dart';
import 'user_repository.dart';

class SendReceivePage extends StatelessWidget {
  const SendReceivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = SendReceiveRepository();
    final lockerRepository = LockerRepository();
    final userRepository = UserRepository();

    return BlocProvider(
      create: (_) => SendReceiveCubit(
        getLockerSizes: GetAvailableLockerSizesUseCase(repository: repository),
        getStorageDurations: GetStorageDurationsUseCase(repository: repository),
        getLockers: GetAvailableLockersUseCase(lockerRepository),
        createOrder: CreateSendReceiveOrderUseCase(repository: repository),
        userRepository: userRepository,
      ),
      child: const SendReceiveScreen(),
    );
  }
}

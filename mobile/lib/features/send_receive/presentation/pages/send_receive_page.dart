import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/send_receive_repository.dart';
import '../../domain/usecases/create_send_receive_order_usecase.dart';
import '../../domain/usecases/get_available_locker_sizes_usecase.dart';
import '../../domain/usecases/get_storage_durations_usecase.dart';
import '../controllers/send_receive_cubit.dart';
import '../send_receive_screen.dart';

class SendReceivePage extends StatelessWidget {
  const SendReceivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = SendReceiveRepository();

    return BlocProvider(
      create: (_) => SendReceiveCubit(
        getLockerSizes: GetAvailableLockerSizesUseCase(repository: repository),
        getStorageDurations: GetStorageDurationsUseCase(repository: repository),
        createOrder: CreateSendReceiveOrderUseCase(repository: repository),
      ),
      child: const SendReceiveScreen(),
    );
  }
}

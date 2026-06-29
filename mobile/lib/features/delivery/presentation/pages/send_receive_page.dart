import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../../../features/locker/data/locker_repository.dart';
import '../../data/delivery_repository.dart';
import '../../domain/usecases/create_send_request_usecase.dart';
import '../../domain/usecases/get_delivery_package_sizes_usecase.dart';
import '../../domain/usecases/submit_receive_code_usecase.dart';
import '../controllers/delivery_cubit.dart';
import '../send_receive_screen.dart';

class SendReceivePage extends StatelessWidget {
  const SendReceivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = DeliveryRepository(ApiClient());
    final lockerRepository = LockerRepository();
    return BlocProvider(
      create: (_) => DeliveryCubit(
        getPackageSizes: GetDeliveryPackageSizes(repository),
        createSendRequest: CreateSendRequest(repository),
        submitReceiveCode: SubmitReceiveCode(repository),
        lockerRepository: lockerRepository,
      )..load(),
      child: const SendReceiveScreen(),
    );
  }
}

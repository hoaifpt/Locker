import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/qr_scanner_repository.dart';
import '../../domain/usecases/get_scan_history_usecase.dart';
import '../../domain/usecases/validate_qr_code_usecase.dart';
import '../controllers/qr_scanner_cubit.dart';
import '../screens/qr_scanner_screen.dart';

class QrScannerPage extends StatelessWidget {
  const QrScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = QrScannerRepository();
    return BlocProvider(
      create: (_) => QrScannerCubit(
        validateQrCode: ValidateQrCodeUsecase(repo),
        getScanHistory: GetScanHistoryUsecase(repo),
      )..startScanning(),
      child: const QrScannerScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import '../../data/locker_overdue_repository.dart';
import '../../domain/usecases/get_overdue_info_usecase.dart';
import '../locker_overdue_penalty_screen.dart';

/// Page that wires the simple repository + usecase and shows the screen.
class LockerOverduePage extends StatelessWidget {
  const LockerOverduePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = LockerOverdueRepository();
    final usecase = GetOverdueInfoUseCase(repository);

    return FutureBuilder(
      future: usecase.call(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(child: Text('Lỗi: \\${snapshot.error}')));
        }
        final info = snapshot.data!;
        return LockerOverduePenaltyScreen(info: info);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/home_repository.dart';
import '../../domain/usecases/get_active_lockers_usecase.dart';
import '../../domain/usecases/get_nearby_lockers_usecase.dart';
import '../controllers/home_cubit.dart';
import '../home_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = HomeRepository();
    return BlocProvider(
      create: (_) => HomeCubit(
        getActiveLockers: GetActiveLockers(repo),
        getNearbyLockers: GetNearbyLockers(repo),
      )..load(),
      child: const HomeScreen(),
    );
  }
}

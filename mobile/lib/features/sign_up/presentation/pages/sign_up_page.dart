import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/sign_up_repository.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../controllers/sign_up_cubit.dart';
import '../screens/sign_up_screen.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = SignUpRepository();

    return BlocProvider(
      create: (_) => SignUpCubit(
        signUpUseCase: SignUpUseCase(repository: repository),
      ),
      child: const SignUpScreen(),
    );
  }
}

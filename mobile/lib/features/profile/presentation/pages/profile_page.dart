import 'package:flutter/material.dart';

import '../../data/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import 'profile_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProfileRepository();
    return ProfileScreen(getProfile: GetProfileUsecase(repository: repo));
  }
}

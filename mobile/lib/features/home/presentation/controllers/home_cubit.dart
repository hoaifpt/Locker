import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../locker/domain/entities/locker.dart';
import '../../domain/entities/active_locker.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_active_lockers_usecase.dart';
import '../../domain/usecases/get_nearby_lockers_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetActiveLockers _getActiveLockers;
  final GetNearbyLockers _getNearbyLockers;
  final GetUserProfile _getUserProfile;

  HomeCubit({
    required GetActiveLockers getActiveLockers,
    required GetNearbyLockers getNearbyLockers,
    required GetUserProfile getUserProfile,
  })  : _getActiveLockers = getActiveLockers,
        _getNearbyLockers = getNearbyLockers,
        _getUserProfile = getUserProfile,
        super(const HomeInitial());

  Future<void> load() async {
    emit(const HomeLoading());
    try {
      final results = await Future.wait([
        _getActiveLockers(),
        _getNearbyLockers(),
        _getUserProfile(),
      ]);
      emit(HomeLoaded(
        activeLockers: results[0] as List<ActiveLocker>,
        nearbyLockers: results[1] as List<Locker>,
        user: results[2] as User,
      ));
    } on AppException catch (e) {
      emit(HomeError(e.message));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}

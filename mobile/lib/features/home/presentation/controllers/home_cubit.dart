import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../domain/usecases/get_active_lockers_usecase.dart';
import '../../domain/usecases/get_nearby_lockers_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetActiveLockers _getActiveLockers;
  final GetNearbyLockers _getNearbyLockers;

  HomeCubit({
    required GetActiveLockers getActiveLockers,
    required GetNearbyLockers getNearbyLockers,
  })  : _getActiveLockers = getActiveLockers,
        _getNearbyLockers = getNearbyLockers,
        super(const HomeInitial());

  Future<void> load() async {
    emit(const HomeLoading());
    try {
      final results = await Future.wait([
        _getActiveLockers(),
        _getNearbyLockers(),
      ]);
      emit(HomeLoaded(
        activeLockers: results[0] as dynamic,
        nearbyLockers: results[1] as dynamic,
      ));
    } on AppException catch (e) {
      emit(HomeError(e.message));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}

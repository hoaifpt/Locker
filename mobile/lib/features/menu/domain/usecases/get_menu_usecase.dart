import '../entities/menu_item.dart';
import '../repositories/i_menu_repository.dart';

class GetMenuUsecase {
  final IMenuRepository _repo;

  GetMenuUsecase(this._repo);

  Future<List<MenuItem>> call(String? restaurantId) {
    return _repo.getMenu(restaurantId);
  }
}

import '../entities/menu_item.dart';

abstract class IMenuRepository {
  Future<List<MenuItem>> getMenu(String? restaurantId);
}

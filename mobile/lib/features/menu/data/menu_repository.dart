import '../../menu/domain/entities/menu_item.dart';
import '../../menu/domain/repositories/i_menu_repository.dart';

class MenuRepository implements IMenuRepository {
  @override
  Future<List<MenuItem>> getMenu(String? restaurantId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    // Simple mocked data; replace with API call later.
    return const [
      MenuItem(
        id: 'm1',
        name: 'Phở Bò Gốc Việt',
        description: 'Nước dùng thanh ngọt hầm 12 tiếng, bánh phở tươi...',
        price: 55000,
        imageUrl: 'https://placehold.co/96x96',
      ),
      MenuItem(
        id: 'm2',
        name: 'Bánh Mì Đặc Biệt',
        description: 'Vỏ bánh giòn rụm, nhân pate gan, xá xíu...',
        price: 35000,
        imageUrl: 'https://placehold.co/96x96',
      ),
      MenuItem(
        id: 'm3',
        name: 'Cao Lầu Hội An',
        description: 'Sợi mì vàng óng, ăn kèm rau sống...',
        price: 45000,
        imageUrl: 'https://placehold.co/96x96',
      ),
    ];
  }
}

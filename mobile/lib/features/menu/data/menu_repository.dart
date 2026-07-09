import 'dart:developer';

import 'package:locker_mobile/core/constants/api_endpoints.dart';
import 'package:locker_mobile/core/network/api_client.dart';
import 'models/menu_item_model.dart';

import '../../menu/domain/entities/menu_item.dart';
import '../../menu/domain/repositories/i_menu_repository.dart';

class MenuRepository implements IMenuRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<List<MenuItem>> getMenu(String? restaurantId) async {
    // Nếu restaurantId là null, không gọi API và trả về danh sách rỗng.
    if (restaurantId == null) {
      log('[MenuRepo] restaurantId is null, returning empty list.');
      return [];
    }

    try {
      final response = await _apiClient.client.get(
        ApiEndpoints.restaurantMenu(restaurantId),
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;

        // Parse JSON sang Model, lọc các món không có sẵn và trả về.
        final items = data
            .map((json) => MenuItemModel.fromJson(json))
            .where((item) => item.isAvailable)
            .toList();
        return items;
      } else {
        log(
          '[MenuRepo] Unexpected response for restaurant $restaurantId: ${response.statusCode}',
        );
        return [];
      }
    } catch (e, stackTrace) {
      log(
        '[MenuRepo] Error fetching menu for restaurant $restaurantId: $e',
        stackTrace: stackTrace,
      );
      return [];
    }
  }
}

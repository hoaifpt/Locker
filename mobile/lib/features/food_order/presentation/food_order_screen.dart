import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;
import 'dart:developer';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:geolocator/geolocator.dart' as geo;
import 'controllers/food_order_cubit.dart';
import 'controllers/food_order_state.dart';
import 'package:locker_mobile/features/restaurant_map/domain/entities/restaurant.dart';
import 'widgets/restaurant_bottom_sheet.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

final GlobalKey<_MapLayerState> _mapLayerKey = GlobalKey();

class FoodOrderScreen extends StatelessWidget {
  const FoodOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: BlocBuilder<FoodOrderCubit, FoodOrderState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFD8D64)),
              );
            }

            return Stack(
              children: [
                // Lớp bản đồ đã được cấu trúc để tích hợp sâu hơn với Mapbox
                _MapLayer(key: _mapLayerKey),
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _TopOverlay(),
                ),
                if (state.selectedPin != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: RestaurantBottomSheet(restaurant: state.selectedPin),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopOverlay extends StatelessWidget {
  const _TopOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      color: Colors.white.withAlpha(217), // 85% opacity
      child: Column(
        children: [
          Row(
            children: [
              _circleIconButton(
                Icons.arrow_back_rounded,
                () => Navigator.pop(context),
              ),
              const Spacer(),
              const Text(
                'Bản đồ',
                style: TextStyle(
                  color: Color(0xFF1A1C1C),
                  fontSize: 20,
                  fontFamily: 'Alexandria',
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              _circleIconButton(Icons.tune_rounded, () {}),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded, color: Color(0xFF85736D)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tìm quán ăn sáng...',
                          style: TextStyle(
                            color: Color(0xFF85736D),
                            fontSize: 14,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  // Gọi hàm định vị thông qua key
                  _mapLayerKey.currentState?.moveToUserLocation();
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFD8D64),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFFF3F3F4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF1A1C1C)),
      ),
    );
  }
}

// Lớp hiển thị bản đồ và các marker
class _MapLayer extends StatefulWidget {
  const _MapLayer({super.key});

  @override
  State<_MapLayer> createState() => _MapLayerState();
}

class _MapLayerState extends State<_MapLayer> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  final Map<String, PointAnnotation> _annotations = {};
  final Map<String, String> _markerToRestaurantIdMap = {};
  bool _initialCameraSet = false;
  List<Restaurant>? _pendingRestaurants;

  // Chuyển thành async để tải icon marker và cải thiện xử lý lỗi
  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    log('[Map] Map created.');

    _mapboxMap?.setCamera(
      CameraOptions(
        center: Point(coordinates: Position(106.7017896, 10.7780127)),
        zoom: 14.0,
      ),
    );

    // ================== KHỐI 1: load ảnh marker ==================
    // Lỗi ở đây (nếu có) sẽ KHÔNG chặn phần tạo PointAnnotationManager ở khối 2
    try {
      final ByteData byteData = await rootBundle.load('assets/green_pin.png');
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final ui.Codec codec = await ui.instantiateImageCodec(pngBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      // Lấy đúng raw RGBA pixel data (đã decode), không dùng bytes PNG nén nữa
      final ByteData? rawRgba = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      if (rawRgba != null) {
        final Uint8List rawBytes = rawRgba.buffer.asUint8List();

        await _mapboxMap?.style.addStyleImage(
          'green-pin',
          1.0,
          MbxImage(
            width: image.width, // ✅ size thật của ảnh, không hardcode 64
            height: image.height, // ✅
            data: rawBytes, // ✅ raw RGBA, không phải PNG nén
          ),
          false,
          <ImageStretches>[],
          <ImageStretches>[],
          null,
        );
        log('[Map] Custom marker image loaded and added to style.');
      }

      image.dispose(); // giải phóng bộ nhớ native, tránh leak
    } catch (e, stackTrace) {
      log(
        '[Map] Lỗi load marker image (bỏ qua, sẽ không có icon custom): $e',
        stackTrace: stackTrace,
      );
    }

    // ================== KHỐI 2: setup manager, luôn chạy ==================
    try {
      _mapboxMap?.setBounds(
        CameraBoundsOptions(
          bounds: CoordinateBounds(
            southwest: Point(coordinates: Position(102.1, 8.0)),
            northeast: Point(coordinates: Position(109.5, 23.4)),
            infiniteBounds: false,
          ),
          minZoom: 5.0,
        ),
      );

      log('[Map] Creating PointAnnotationManager...');
      final manager = await mapboxMap.annotations
          .createPointAnnotationManager();
      _pointAnnotationManager = manager;
      log('[Map] PointAnnotationManager created successfully.');

      manager.tapEvents(
        onTap: (tappedAnnotation) {
          log('[Map] Tapped annotation: ${tappedAnnotation.id}');
          final restaurantId = _markerToRestaurantIdMap[tappedAnnotation.id];
          if (restaurantId != null) {
            log('[Map] Selecting restaurant: $restaurantId');
            context.read<FoodOrderCubit>().selectRestaurant(restaurantId);
          } else {
            log(
              '[Map] Restaurant ID not found for annotation ${tappedAnnotation.id}',
            );
          }
        },
      );

      final currentState = context.read<FoodOrderCubit>().state;
      log(
        '[Map] Checking initial state: ${currentState.restaurants.length} restaurants, isLoading: ${currentState.isLoading}',
      );
      if (currentState.restaurants.isNotEmpty) {
        log('[Map] Initial data found, updating annotations.');
        _updateAnnotations(currentState.restaurants);
      } else {
        log('[Map] No initial data yet - BlocListener will handle updates');
      }

      _showUserLocation();
    } catch (e, stackTrace) {
      log(
        '[Map] Error creating annotation manager: $e',
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> moveToUserLocation() async {
    log('[Debug] Nút cam đã được bấm, đang bắt đầu định vị...');
    try {
      // 1. Kiểm tra và xin quyền
      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }

      if (permission == geo.LocationPermission.whileInUse ||
          permission == geo.LocationPermission.always) {
        // 2. Lấy vị trí với cách gọi đơn giản của v11
        // Lưu ý: Không cần 'locationSettings' nữa, truyền thẳng accuracy
        geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high,
        );

        log("Vị trí GPS: ${position.latitude}, ${position.longitude}");

        // 3. Bay tới vị trí
        _mapboxMap?.flyTo(
          mapbox.CameraOptions(
            center: mapbox.Point(
              coordinates: mapbox.Position(
                position.longitude,
                position.latitude,
              ),
            ),
            zoom: 15.0,
          ),
          mapbox.MapAnimationOptions(duration: 1000),
        );
      }
    } catch (e) {
      log("Lỗi định vị: $e");
    }
  }

  Future<void> _updateAnnotations(List<Restaurant> restaurants) async {
    if (_pointAnnotationManager == null || !mounted) {
      log(
        '[Map] Annotation manager not ready or widget not mounted. Skipping update.',
      );
      return;
    }

    log(
      '[Map] _updateAnnotations called with ${restaurants.length} restaurants',
    );

    final options = restaurants.map((res) {
      log(
        '[Map] Creating annotation for ${res.name} - lat: ${res.latitude}, lng: ${res.longitude}',
      );
      return mapbox.PointAnnotationOptions(
        geometry: mapbox.Point(
          coordinates: mapbox.Position(res.longitude, res.latitude),
        ),
        iconImage: 'green-pin',
        iconSize: 0.8,
      );
    }).toList();

    await _pointAnnotationManager?.deleteAll();
    _annotations.clear();
    _markerToRestaurantIdMap.clear();

    if (options.isNotEmpty) {
      log('[Map] Creating ${options.length} annotations...');
      try {
        final newAnnotations = await _pointAnnotationManager?.createMulti(
          options,
        );
        log(
          '[Map] Created ${newAnnotations?.length ?? 0} new annotations successfully.',
        );
        if (newAnnotations != null) {
          for (int i = 0; i < newAnnotations.length; i++) {
            final PointAnnotation? annotation = newAnnotations[i];
            if (annotation != null) {
              final res = restaurants[i];
              if (res.id.isNotEmpty) {
                _annotations[res.id] = annotation;
                _markerToRestaurantIdMap[annotation.id] = res.id;
                log(
                  '[Map] Mapped annotation ${annotation.id} to restaurant ${res.name}',
                );
              }
            }
          }
        }
      } catch (e, stackTrace) {
        log('[Map] Error creating annotations: $e', stackTrace: stackTrace);
      }
    } else {
      log('[Map] No options to create - restaurants list may be empty');
    }
  }

  void _showUserLocation() {
    _mapboxMap?.location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );
  }

  void _flyTo(Restaurant restaurant) {
    _mapboxMap?.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(restaurant.longitude, restaurant.latitude),
        ),
        zoom: 16.0,
        pitch: 0.0,
      ),
      MapAnimationOptions(duration: 1500, startDelay: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FoodOrderCubit, FoodOrderState>(
      listener: (context, state) {
        log(
          '[Screen] BlocListener triggered - restaurants: ${state.restaurants.length}, isLoading: ${state.isLoading}',
        );

        if (state.restaurants.isNotEmpty) {
          log(
            '[Screen] BlocListener: ${state.restaurants.length} restaurants received, calling _updateAnnotations',
          );
          _updateAnnotations(
            state.restaurants,
          ); // ✅ luôn gọi, _updateAnnotations tự check null
        } else {
          log('[Screen] BlocListener: restaurants list is empty');
        }

        if (state.selectedRestaurant != null) {
          log(
            '[Screen] Selected restaurant: ${state.selectedRestaurant?.name}',
          );
          _flyTo(state.selectedRestaurant!);
        }

        if (state.restaurants.isNotEmpty && !_initialCameraSet) {
          log('[Screen] Setting initial camera position');
          _mapboxMap?.setCamera(
            CameraOptions(
              center: Point(
                coordinates: Position(
                  state.restaurants.first.longitude,
                  state.restaurants.first.latitude,
                ),
              ),
              zoom: 14.5,
            ),
          );
          _initialCameraSet = true;
        }
      },

      child: GestureDetector(
        // ✅ BỌC MapWidget
        onTap: () {
          log('[Map] Click vùng trống');
          context.read<FoodOrderCubit>().selectRestaurant("");
        },
        child: MapWidget(
          key: const ValueKey("mapview"),
          styleUri: 'mapbox://styles/hoai/cmqrnr7qe000o01sifrrmhpr5',
          onMapCreated: _onMapCreated,
          onMapLoadErrorListener: (error) {
            log('[Map] A map error occurred: ${error.message}');
          },
        ),
      ),
    );
  }
}

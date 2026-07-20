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

class _TopOverlay extends StatefulWidget {
  const _TopOverlay();

  @override
  State<_TopOverlay> createState() => _TopOverlayState();
}

class _TopOverlayState extends State<_TopOverlay> {
  final _searchController = TextEditingController();
  // Flag to prevent search listener from firing when text is updated programmatically
  bool _isProgrammaticChange = false;

  void _onSearchChanged() {
    if (_isProgrammaticChange) return;
    context.read<FoodOrderCubit>().search(_searchController.text);
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This listener handles updating the search TextField when a restaurant is
    // selected from the map/list or when the selection is cleared.
    return BlocListener<FoodOrderCubit, FoodOrderState>(
      listenWhen: (previous, current) =>
          previous.selectedRestaurantId != current.selectedRestaurantId,
      listener: (context, state) {
        final newText = state.selectedRestaurant?.name ?? '';
        if (_searchController.text != newText) {
          _isProgrammaticChange = true;
          _searchController.text = newText;
          _isProgrammaticChange = false;
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        color: Colors.white.withAlpha(217), // 85% opacity
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    // Search Bar
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF85736D),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Tìm quán ăn sáng...',
                              hintStyle: TextStyle(
                                color: Color(0xFF85736D),
                                fontSize: 14,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              color: Color(0xFF1A1C1C),
                              fontSize: 14,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w500,
                            ),
                            textAlignVertical: TextAlignVertical.center,
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
            _buildSearchResults(),
          ],
        ),
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

  Widget _buildSearchResults() {
    return BlocBuilder<FoodOrderCubit, FoodOrderState>(
      buildWhen: (previous, current) =>
          previous.searchQuery != current.searchQuery ||
          previous.searchResults != current.searchResults,
      builder: (context, state) {
        if (state.searchQuery.isEmpty) {
          return const SizedBox.shrink(); // Hide when not searching
        }

        return Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.only(top: 8.0),
            constraints: const BoxConstraints(
              maxHeight: 220, // Limit height
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: state.searchResults.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No restaurants found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: state.searchResults.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final restaurant = state.searchResults[index];
                        return ListTile(
                          title: Text(
                            restaurant.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            restaurant.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            context.read<FoodOrderCubit>().selectRestaurant(
                              restaurant.id,
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        );
      },
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
  mapbox.MapboxMap? _mapboxMap;
  mapbox.PointAnnotationManager? _pointAnnotationManager;
  final Map<String, mapbox.PointAnnotation> _annotations = {};
  // Maps the Mapbox-generated annotation ID back to our restaurant ID
  final Map<String, String> _markerToRestaurantIdMap = {};
  bool _initialCameraSet = false;
  bool _isStyleLoaded = false;

  // Called when the map controller is ready.
  // We initialize non-style-dependent components here.
  void _onMapCreated(mapbox.MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    debugPrint('[Map] Map created.');

    // Set camera constraints early.
    _mapboxMap?.setBounds(
      mapbox.CameraBoundsOptions(
        bounds: mapbox.CoordinateBounds(
          southwest: mapbox.Point(coordinates: mapbox.Position(102.1, 8.0)),
          northeast: mapbox.Point(coordinates: mapbox.Position(109.5, 23.4)),
          infiniteBounds: false,
        ),
        minZoom: 5.0,
      ),
    );

    // Create the annotation manager. This is not style-dependent.
    log('[Map] Creating PointAnnotationManager...');
    try {
      final manager = await mapboxMap.annotations
          .createPointAnnotationManager();
      _pointAnnotationManager = manager;
      log('[Map] PointAnnotationManager created successfully.');

      // For SDK v2.25.0, use tapEvents to handle marker taps.
      _pointAnnotationManager?.tapEvents(
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
    } catch (e, stackTrace) {
      log(
        '[Map] Error creating annotation manager: $e',
        stackTrace: stackTrace,
      );
    }

    // Show the user's blue dot location.
    _showUserLocation();
  }

  /// Called when the map style has finished loading.
  /// This is the correct and safe place to add images, sources, or layers.
  void _onStyleLoaded(mapbox.StyleLoadedEventData _) async {
    debugPrint('[Map] Style loaded.');
    _isStyleLoaded = true;

    // 2. Now that the style and image are ready, check for initial data
    //    that might have loaded before the map was ready.
    final currentState = context.read<FoodOrderCubit>().state;
    if (currentState.restaurants.isNotEmpty) {
      log('[Map] Style loaded, initial data found. Updating annotations.');
      await _updateAnnotations(currentState.restaurants);
    }
  }

  /// Loads the marker PNG from assets and adds it to the map's style.
  Future<void> _addMarkerImageToStyle() async {
    try {
      log("========= TEST IMAGE =========");

      final ByteData byteData = await rootBundle.load("assets/green_pin.png");

      debugPrint("Asset bytes = ${byteData.lengthInBytes}");

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final ui.Codec codec = await ui.instantiateImageCodec(pngBytes);

      final ui.FrameInfo frameInfo = await codec.getNextFrame();

      final ui.Image image = frameInfo.image;

      debugPrint("Image width = ${image.width}");
      debugPrint("Image height = ${image.height}");

      final ByteData? rawRgbaBytes = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      debugPrint("raw bytes null = ${rawRgbaBytes == null}");

      if (rawRgbaBytes != null) {
        debugPrint("raw bytes = ${rawRgbaBytes.lengthInBytes}");
      }

      if (rawRgbaBytes == null) {
        debugPrint(
          '[Map] CRITICAL: Failed to decode image to raw RGBA format.',
        );
        return;
      }

      await _mapboxMap?.style.addStyleImage(
        'green-pin', // The ID we will use to reference this image.
        1.0,
        mapbox.MbxImage(
          width: image.width,
          height: image.height,
          data: rawRgbaBytes.buffer.asUint8List(),
        ),
        false, // sdf
        <mapbox.ImageStretches>[],
        <mapbox.ImageStretches>[],
        null,
      );
      debugPrint(
        '[Map] Custom marker image "green-pin" (Size: ${image.width}x${image.height}) added to style.',
      );
      image.dispose(); // Release native resources
    } catch (e, stackTrace) {
      log(
        '[Map] CRITICAL: Error loading marker image. Markers will not appear. Error: $e',
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> moveToUserLocation() async {
    log('[Map] Moving to user location...');
    try {
      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }

      if (permission != geo.LocationPermission.whileInUse &&
          permission != geo.LocationPermission.always) {
        log('[Map] Location permission not granted.');
        return;
      }

      try {
        geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high,
        );

        log(
          "[Map] User GPS location: ${position.latitude}, ${position.longitude}",
        );

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
          mapbox.MapAnimationOptions(duration: 1200),
        );
      } on geo.LocationServiceDisabledException {
        log('[Map] Location service is disabled.');
        // Optionally, show a dialog to ask the user to enable it.
      }
    } catch (e) {
      log("[Map] Error getting user location: $e");
    }
  }

  /// Creates, updates, or deletes annotations on the map to match the list of restaurants.
  Future<void> _updateAnnotations(List<Restaurant> restaurants) async {
    // Guard against running before the manager or style is ready.
    if (_pointAnnotationManager == null || !_isStyleLoaded || !mounted) {
      log(
        '[Map] Annotation manager or style not ready. Will retry on next state change.',
      );
      return;
    }

    log('[Map] Updating annotations for ${restaurants.length} restaurants.');

    // This is a simplified approach. For large datasets, a diffing algorithm
    // would be more performant than deleteAll/createMulti.
    await _pointAnnotationManager?.deleteAll();
    _annotations.clear();
    _markerToRestaurantIdMap.clear();

    if (restaurants.isEmpty) {
      log('[Map] Restaurants list is empty, no annotations to create.');
      return;
    }

    final Uint8List markerBytes = (await rootBundle.load(
      "assets/green_pin.png",
    )).buffer.asUint8List();

    final options = restaurants.map((res) {
      return mapbox.PointAnnotationOptions(
        geometry: mapbox.Point(
          coordinates: mapbox.Position(res.longitude, res.latitude),
        ),
        image: markerBytes, // This MUST match the ID used in addStyleImage.
        iconSize: 0.8,
      );
    }).toList();

    try {
      final newAnnotations = await _pointAnnotationManager?.createMulti(
        options,
      );
      if (newAnnotations != null) {
        log('[Map] Created ${newAnnotations.length} annotations successfully.');
        for (int i = 0; i < newAnnotations.length; i++) {
          final annotation = newAnnotations[i];
          if (annotation != null) {
            final restaurant = restaurants[i];
            _annotations[restaurant.id] = annotation;
            _markerToRestaurantIdMap[annotation.id] = restaurant.id;
          }
        }
        log('[Map] Annotation mapping complete.');
      }
    } catch (e) {
      log('[Map] Error during createMulti: $e');
    }
  }

  void _showUserLocation() {
    _mapboxMap?.location.updateSettings(
      mapbox.LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );
  }

  void _flyTo(Restaurant restaurant) {
    _mapboxMap?.flyTo(
      mapbox.CameraOptions(
        center: mapbox.Point(
          coordinates: mapbox.Position(
            restaurant.longitude,
            restaurant.latitude,
          ),
        ),
        zoom: 16.0,
        pitch: 0.0,
      ),
      mapbox.MapAnimationOptions(duration: 1500, startDelay: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FoodOrderCubit, FoodOrderState>(
      listener: (context, state) {
        if (state.restaurants.isNotEmpty) {
          log(
            '[BlocListener] Received ${state.restaurants.length} restaurants, updating annotations.',
          );
          // DO NOT await in a listener. The _updateAnnotations method has its own
          // guards to handle being called before the map is ready.
          _updateAnnotations(state.restaurants);
        }

        if (state.selectedRestaurant != null) {
          log(
            '[BlocListener] Selected restaurant: ${state.selectedRestaurant?.name}, flying to location.',
          );
          _flyTo(state.selectedRestaurant!);
        }

        if (state.restaurants.isNotEmpty && !_initialCameraSet) {
          log('[Screen] Setting initial camera position');
          _mapboxMap?.setCamera(
            mapbox.CameraOptions(
              center: mapbox.Point(
                coordinates: mapbox.Position(
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

      // For SDK v2.25.0, wrap with GestureDetector to handle background taps.
      child: GestureDetector(
        onTap: () {
          log('[Map] Clicked on map background, clearing selection.');
          context.read<FoodOrderCubit>().clearSelection();
        },
        child: mapbox.MapWidget(
          key: const ValueKey("mapview"),
          styleUri: 'mapbox://styles/hoai/cmqrnr7qe000o01sifrrmhpr5',
          onMapCreated: _onMapCreated,
          onStyleLoadedListener: _onStyleLoaded,
          onMapLoadErrorListener: (error) {
            debugPrint('[Map] A map error occurred: ${error.message}');
          },
        ),
      ),
    );
  }
}

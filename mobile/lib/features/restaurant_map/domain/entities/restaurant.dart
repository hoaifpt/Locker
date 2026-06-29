import 'package:equatable/equatable.dart';

/// {@template restaurant}
/// Pure domain entity for a restaurant.
/// {@endtemplate}
class Restaurant extends Equatable {
  /// {@macro restaurant}
  const Restaurant({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.imageUrl,
    required this.address,
    required this.isOpen,
    required this.distanceKm,
    required this.description,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double rating;
  final String imageUrl;
  final String address;
  final bool isOpen;
  final double distanceKm;
  final String description;

  @override
  List<Object?> get props => [
        id,
        name,
        latitude,
        longitude,
        rating,
        imageUrl,
        address,
        isOpen,
        distanceKm,
        description,
      ];
}

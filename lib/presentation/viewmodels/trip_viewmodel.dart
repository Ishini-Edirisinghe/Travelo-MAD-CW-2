import 'package:flutter/material.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/entities/trip_entity.dart';

class TripViewModel extends ChangeNotifier {
  final TripRepositoryImpl repository;

  List<TripEntity> _trips = [];
  List<TripEntity> get trips => _trips;

  // Getter for Favorite Trips (Filters the main list)
  List<TripEntity> get favoriteTrips =>
      _trips.where((trip) => trip.isFavorite).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TripViewModel({required this.repository}) {
    loadTrips();
  }

  // Initial Load (Shows Spinner)
  Future<void> loadTrips() async {
    _isLoading = true;
    notifyListeners();
    try {
      _trips = await repository.getTrips();
    } catch (e) {
      debugPrint("Error loading trips: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTrip(TripEntity trip) async {
    await repository.addTrip(trip);
    await loadTrips();
  }

  Future<void> deleteTrip(String id) async {
    await repository.deleteTrip(id);
    await loadTrips();
  }

  // UPDATED: Toggle Favorite (No Spinner Flash)
  Future<void> toggleFavorite(TripEntity trip) async {
    // 1. Create a new entity with the flipped boolean status
    final updatedTrip = TripEntity(
      id: trip.id,
      title: trip.title,
      startDate: trip.startDate,
      endDate: trip.endDate,
      description: trip.description,
      imagePath: trip.imagePath,
      isFavorite: !trip.isFavorite, // Flip status here
    );

    // 2. Update in Database
    await repository.updateTrip(updatedTrip);

    // 3. Refresh List Silently
    // We do NOT call loadTrips() here to avoid the loading spinner appearing.
    // Instead, we fetch the data and notify listeners directly.
    _trips = await repository.getTrips();
    notifyListeners();
  }
}

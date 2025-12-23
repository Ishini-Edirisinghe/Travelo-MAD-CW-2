import 'package:flutter/material.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/entities/trip_entity.dart';

class TripViewModel extends ChangeNotifier {
  final TripRepositoryImpl repository;

  List<TripEntity> _trips = [];
  List<TripEntity> get trips => _trips;

  List<TripEntity> get favoriteTrips =>
      _trips.where((trip) => trip.isFavorite).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TripViewModel({required this.repository}) {
    loadTrips();
  }
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

  Future<void> toggleFavorite(TripEntity trip) async {
    final updatedTrip = TripEntity(
      id: trip.id,
      title: trip.title,
      startDate: trip.startDate,
      endDate: trip.endDate,
      description: trip.description,
      imagePath: trip.imagePath,
      isFavorite: !trip.isFavorite,
    );

    await repository.updateTrip(updatedTrip);
    _trips = await repository.getTrips();
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/entities/trip_entity.dart';

class TripViewModel extends ChangeNotifier {
  final TripRepositoryImpl repository;

  List<TripEntity> _trips = [];
  List<TripEntity> get trips => _trips;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TripViewModel({required this.repository}) {
    loadTrips(); // Load data immediately when initialized
  }

  Future<void> loadTrips() async {
    _isLoading = true;
    notifyListeners();

    _trips = await repository.getTrips();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTrip(TripEntity trip) async {
    await repository.addTrip(trip);
    await loadTrips(); // Refresh list after adding
  }

  Future<void> deleteTrip(String id) async {
    await repository.deleteTrip(id);
    await loadTrips(); // Refresh list after deleting
  }
}

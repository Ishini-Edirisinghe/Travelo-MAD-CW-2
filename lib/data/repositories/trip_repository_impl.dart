import '../../domain/entities/trip_entity.dart';
import '../datasources/local_datasource.dart';
import '../models/trip_model.dart';

class TripRepositoryImpl {
  final LocalDataSource dataSource;

  TripRepositoryImpl({required this.dataSource});

  Future<void> addTrip(TripEntity trip) async {
    final tripModel = TripModel(
      id: trip.id,
      title: trip.title,
      startDate: trip.startDate,
      endDate: trip.endDate,
      description: trip.description,
      imagePath: trip.imagePath,
    );
    await dataSource.insertTrip(tripModel);
  }

  Future<List<TripEntity>> getTrips() async {
    return await dataSource.getTrips();
  }

  Future<void> deleteTrip(String id) async {
    await dataSource.deleteTrip(id);
  }
}

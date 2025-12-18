class TripEntity {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final String? imagePath;

  TripEntity({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.description,
    this.imagePath,
  });
}

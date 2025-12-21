import '../../domain/entities/trip_entity.dart';

class TripModel extends TripEntity {
  TripModel({
    required super.id,
    required super.title,
    required super.startDate,
    required super.endDate,
    required super.description,
    super.imagePath,
    super.isFavorite,
  });

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'],
      title: map['title'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      description: map['description'],
      imagePath: map['imagePath'],
      // Convert Integer (0/1) from DB to Boolean
      isFavorite: (map['isFavorite'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'description': description,
      'imagePath': imagePath,
      // Convert Boolean to Integer (0/1) for DB
      'isFavorite': isFavorite ? 1 : 0,
    };
  }
}

// import '../../domain/entities/trip_entity.dart';

// class TripModel extends TripEntity {
//   TripModel({
//     required super.id,
//     required super.title,
//     required super.startDate,
//     required super.endDate,
//     required super.description,
//     super.imagePath,
//   });

//   // Convert Map (Database) -> Object
//   factory TripModel.fromMap(Map<String, dynamic> map) {
//     return TripModel(
//       id: map['id'],
//       title: map['title'],
//       startDate: DateTime.parse(map['startDate']),
//       endDate: DateTime.parse(map['endDate']),
//       description: map['description'],
//       imagePath: map['imagePath'],
//     );
//   }

//   // Convert Object -> Map (Database)
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'title': title,
//       'startDate': startDate.toIso8601String(),
//       'endDate': endDate.toIso8601String(),
//       'description': description,
//       'imagePath': imagePath,
//     };
//   }
// }

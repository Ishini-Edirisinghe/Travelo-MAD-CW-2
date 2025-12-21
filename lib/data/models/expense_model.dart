import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  ExpenseModel({
    required super.id,
    required super.tripId,
    required super.amount,
    required super.category,
    required super.date,
    required super.note,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      tripId: map['tripId'],
      // FIX: Robust casting to handle int or double from DB
      amount: (map['amount'] as num).toDouble(),
      category: map['category'],
      date: DateTime.parse(map['date']),
      note: map['note'] ?? '', // Handle null notes
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}

// import '../../domain/entities/expense_entity.dart';

// class ExpenseModel extends ExpenseEntity {
//   ExpenseModel({
//     required super.id,
//     required super.tripId,
//     required super.amount,
//     required super.category,
//     required super.date,
//     required super.note,
//   });

//   factory ExpenseModel.fromMap(Map<String, dynamic> map) {
//     return ExpenseModel(
//       id: map['id'],
//       tripId: map['tripId'],
//       amount: map['amount'],
//       category: map['category'],
//       date: DateTime.parse(map['date']),
//       note: map['note'],
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'tripId': tripId,
//       'amount': amount,
//       'category': category,
//       'date': date.toIso8601String(),
//       'note': note,
//     };
//   }
// }

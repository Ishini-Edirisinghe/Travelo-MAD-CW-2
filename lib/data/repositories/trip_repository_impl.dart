import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/expense_entity.dart';
import '../datasources/local_datasource.dart';
import '../models/trip_model.dart';
import '../models/expense_model.dart';

class TripRepositoryImpl {
  final LocalDataSource dataSource;

  TripRepositoryImpl(this.dataSource);

  // --- TRIPS ---
  Future<void> addTrip(TripEntity trip) async {
    final tripModel = TripModel(
      id: trip.id,
      title: trip.title,
      startDate: trip.startDate,
      endDate: trip.endDate,
      description: trip.description,
      imagePath: trip.imagePath,
      isFavorite: trip.isFavorite,
    );
    await dataSource.insertTrip(tripModel);
  }

  Future<List<TripEntity>> getTrips() async {
    return await dataSource.getTrips();
  }

  Future<void> updateTrip(TripEntity trip) async {
    final tripModel = TripModel(
      id: trip.id,
      title: trip.title,
      startDate: trip.startDate,
      endDate: trip.endDate,
      description: trip.description,
      imagePath: trip.imagePath,
      isFavorite: trip.isFavorite,
    );
    await dataSource.updateTrip(tripModel);
  }

  Future<void> deleteTrip(String id) async {
    await dataSource.deleteTrip(id);
  }

  // --- EXPENSES ---
  Future<void> addExpense(ExpenseEntity expense) async {
    final expenseModel = ExpenseModel(
      id: expense.id,
      tripId: expense.tripId,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      note: expense.note,
    );
    await dataSource.insertExpense(expenseModel);
  }

  Future<List<ExpenseEntity>> getExpenses(String tripId) async {
    return await dataSource.getExpenses(tripId);
  }

  // NEW: Update Expense
  Future<void> updateExpense(ExpenseEntity expense) async {
    final expenseModel = ExpenseModel(
      id: expense.id,
      tripId: expense.tripId,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      note: expense.note,
    );
    await dataSource.updateExpense(expenseModel);
  }

  Future<void> deleteExpense(String id) async {
    await dataSource.deleteExpense(id);
  }
}

// import '../../domain/entities/trip_entity.dart';
// import '../../domain/entities/expense_entity.dart';
// import '../datasources/local_datasource.dart';
// import '../models/trip_model.dart';
// import '../models/expense_model.dart';

// class TripRepositoryImpl {
//   final LocalDataSource dataSource;

//   TripRepositoryImpl(this.dataSource);

//   // --- TRIPS ---
//   Future<void> addTrip(TripEntity trip) async {
//     final tripModel = TripModel(
//       id: trip.id,
//       title: trip.title,
//       startDate: trip.startDate,
//       endDate: trip.endDate,
//       description: trip.description,
//       imagePath: trip.imagePath,
//       isFavorite: trip.isFavorite, // <--- ADDED THIS LINE
//     );
//     await dataSource.insertTrip(tripModel);
//   }

//   Future<List<TripEntity>> getTrips() async {
//     return await dataSource.getTrips();
//   }

//   Future<void> updateTrip(TripEntity trip) async {
//     final tripModel = TripModel(
//       id: trip.id,
//       title: trip.title,
//       startDate: trip.startDate,
//       endDate: trip.endDate,
//       description: trip.description,
//       imagePath: trip.imagePath,
//       isFavorite: trip.isFavorite, // <--- CRITICAL FIX: Was missing!
//     );
//     await dataSource.updateTrip(tripModel);
//   }

//   Future<void> deleteTrip(String id) async {
//     await dataSource.deleteTrip(id);
//   }

//   // --- EXPENSES (Unchanged) ---
//   Future<void> addExpense(ExpenseEntity expense) async {
//     final expenseModel = ExpenseModel(
//       id: expense.id,
//       tripId: expense.tripId,
//       amount: expense.amount,
//       category: expense.category,
//       date: expense.date,
//       note: expense.note,
//     );
//     await dataSource.insertExpense(expenseModel);
//   }

//   Future<List<ExpenseEntity>> getExpenses(String tripId) async {
//     return await dataSource.getExpenses(tripId);
//   }

//   Future<void> deleteExpense(String id) async {
//     await dataSource.deleteExpense(id);
//   }
// }

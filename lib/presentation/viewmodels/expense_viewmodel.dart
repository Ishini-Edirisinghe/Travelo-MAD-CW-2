import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseViewModel extends ChangeNotifier {
  final TripRepositoryImpl repository;

  List<ExpenseEntity> _expenses = [];
  List<ExpenseEntity> get expenses => _expenses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ExpenseViewModel({required this.repository});

  Future<void> loadExpenses(String tripId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await repository.getExpenses(tripId);
    } catch (e) {
      print("ERROR LOADING EXPENSES: $e");
      _expenses = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense({
    required String tripId,
    required double amount,
    required String category,
    required DateTime date,
    required String note,
  }) async {
    try {
      final newExpense = ExpenseEntity(
        id: const Uuid().v4(),
        tripId: tripId,
        amount: amount,
        category: category,
        date: date,
        note: note,
      );

      await repository.addExpense(newExpense);

      // Reload to update the UI
      await loadExpenses(tripId);
    } catch (e) {
      print("ERROR ADDING EXPENSE: $e");
      rethrow; // Pass error to UI
    }
  }

  double get totalExpenses =>
      _expenses.fold(0.0, (sum, item) => sum + item.amount);

  Map<String, double> get categoryBreakdown {
    final Map<String, double> breakdown = {};
    for (var expense in _expenses) {
      breakdown[expense.category] =
          (breakdown[expense.category] ?? 0) + expense.amount;
    }
    return breakdown;
  }
}
// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
// import '../../data/repositories/trip_repository_impl.dart';
// import '../../domain/entities/expense_entity.dart';

// class ExpenseViewModel extends ChangeNotifier {
//   final TripRepositoryImpl repository;

//   List<ExpenseEntity> _expenses = [];
//   List<ExpenseEntity> get expenses => _expenses;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   ExpenseViewModel({required this.repository});

//   // lib/presentation/viewmodels/expense_viewmodel.dart

//   Future<void> loadExpenses(String tripId) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       // Attempt to load data
//       _expenses = await repository.getExpenses(tripId);
//     } catch (e) {
//       // If there is an error (like missing table), catch it here
//       print("Error loading expenses: $e");
//       _expenses = []; // Fallback to empty list
//     } finally {
//       // This block runs NO MATTER WHAT (success or error)
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Add a new expense
//   Future<void> addExpense({
//     required String tripId,
//     required double amount,
//     required String category,
//     required DateTime date,
//     required String note,
//   }) async {
//     final newExpense = ExpenseEntity(
//       id: const Uuid().v4(),
//       tripId: tripId,
//       amount: amount,
//       category: category,
//       date: date,
//       note: note,
//     );

//     await repository.addExpense(newExpense);
//     await loadExpenses(tripId); // Refresh list
//   }

//   // Helper: Calculate Total Expenses
//   double get totalExpenses {
//     return _expenses.fold(0.0, (sum, item) => sum + item.amount);
//   }

//   // Helper: Get Expenses by Category for Charts/Stats
//   Map<String, double> get categoryBreakdown {
//     final Map<String, double> breakdown = {};
//     for (var expense in _expenses) {
//       if (breakdown.containsKey(expense.category)) {
//         breakdown[expense.category] =
//             breakdown[expense.category]! + expense.amount;
//       } else {
//         breakdown[expense.category] = expense.amount;
//       }
//     }
//     return breakdown;
//   }
// }

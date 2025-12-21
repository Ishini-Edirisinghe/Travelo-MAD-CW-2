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

  // Load expenses for a specific trip
  Future<void> loadExpenses(String tripId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await repository.getExpenses(tripId);
    } catch (e) {
      debugPrint("ERROR LOADING EXPENSES: $e");
      _expenses = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add a new expense
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
      await loadExpenses(tripId); // Refresh list
    } catch (e) {
      debugPrint("ERROR ADDING EXPENSE: $e");
      rethrow;
    }
  }

  // Update Expense
  Future<void> updateExpense({
    required String id,
    required String tripId,
    required double amount,
    required String category,
    required DateTime date,
    required String note,
  }) async {
    final updatedExpense = ExpenseEntity(
      id: id,
      tripId: tripId,
      amount: amount,
      category: category,
      date: date,
      note: note,
    );
    await repository.updateExpense(updatedExpense);
    await loadExpenses(tripId);
  }

  // Delete Expense
  Future<void> deleteExpense(String expenseId, String tripId) async {
    await repository.deleteExpense(expenseId);
    await loadExpenses(tripId);
  }

  // --- STATISTICS GETTERS (Fixes your errors) ---

  // 1. Total Expenses
  double get totalExpenses =>
      _expenses.fold(0.0, (sum, item) => sum + item.amount);

  // 2. Category Breakdown
  Map<String, double> get categoryBreakdown {
    final Map<String, double> breakdown = {};
    for (var expense in _expenses) {
      breakdown[expense.category] =
          (breakdown[expense.category] ?? 0) + expense.amount;
    }
    return breakdown;
  }

  // 3. Daily Average
  double get dailyAverage {
    if (_expenses.isEmpty) return 0.0;
    // Get unique dates based on Year-Month-Day
    final uniqueDates = _expenses
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();
    if (uniqueDates.isEmpty) return 0.0;
    return totalExpenses / uniqueDates.length;
  }

  // 4. Highest Expense Category
  MapEntry<String, double> get highestExpenseCategory {
    final breakdown = categoryBreakdown;
    if (breakdown.isEmpty) return const MapEntry("None", 0.0);

    // Sort entries by value and get the last one (highest)
    var entries = breakdown.entries.toList();
    entries.sort((a, b) => a.value.compareTo(b.value));
    return entries.last;
  }

  // 5. Lowest Expense Category
  MapEntry<String, double> get lowestExpenseCategory {
    final breakdown = categoryBreakdown;
    if (breakdown.isEmpty) return const MapEntry("None", 0.0);

    // Sort entries by value and get the first one (lowest)
    var entries = breakdown.entries.toList();
    entries.sort((a, b) => a.value.compareTo(b.value));
    return entries.first;
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

//   Future<void> loadExpenses(String tripId) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       _expenses = await repository.getExpenses(tripId);
//     } catch (e) {
//       print("ERROR LOADING EXPENSES: $e");
//       _expenses = [];
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<void> addExpense({
//     required String tripId,
//     required double amount,
//     required String category,
//     required DateTime date,
//     required String note,
//   }) async {
//     try {
//       final newExpense = ExpenseEntity(
//         id: const Uuid().v4(),
//         tripId: tripId,
//         amount: amount,
//         category: category,
//         date: date,
//         note: note,
//       );

//       await repository.addExpense(newExpense);
//       await loadExpenses(tripId);
//     } catch (e) {
//       print("ERROR ADDING EXPENSE: $e");
//       rethrow;
//     }
//   }

//   // --- STATS HELPERS ---

//   double get totalExpenses =>
//       _expenses.fold(0.0, (sum, item) => sum + item.amount);

//   Map<String, double> get categoryBreakdown {
//     final Map<String, double> breakdown = {};
//     for (var expense in _expenses) {
//       breakdown[expense.category] =
//           (breakdown[expense.category] ?? 0) + expense.amount;
//     }
//     return breakdown;
//   }

//   // Insight: Average spending per day (based on recorded expense dates)
//   double get dailyAverage {
//     if (_expenses.isEmpty) return 0.0;
//     // Get unique dates
//     final uniqueDates = _expenses
//         .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
//         .toSet();
//     if (uniqueDates.isEmpty) return 0.0;
//     return totalExpenses / uniqueDates.length;
//   }

//   // Insight: Category with highest spend
//   MapEntry<String, double> get highestExpenseCategory {
//     final breakdown = categoryBreakdown;
//     if (breakdown.isEmpty) return const MapEntry("None", 0.0);

//     return breakdown.entries.reduce((a, b) => a.value > b.value ? a : b);
//   }

//   // Insight: Category with lowest spend
//   MapEntry<String, double> get lowestExpenseCategory {
//     final breakdown = categoryBreakdown;
//     if (breakdown.isEmpty) return const MapEntry("None", 0.0);

//     return breakdown.entries.reduce((a, b) => a.value < b.value ? a : b);
//   }
// }

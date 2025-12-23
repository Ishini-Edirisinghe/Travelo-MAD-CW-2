class ExpenseEntity {
  final String id;
  final String tripId;
  final double amount;
  final String category;
  final DateTime date;
  final String note;

  ExpenseEntity({
    required this.id,
    required this.tripId,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
  });
}

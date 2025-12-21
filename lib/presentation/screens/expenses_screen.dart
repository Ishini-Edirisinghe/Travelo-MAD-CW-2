import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/expense_viewmodel.dart';
import 'add_expense_screen.dart';
import 'expense_summary_screen.dart';

class ExpensesScreen extends StatefulWidget {
  final String tripId;

  const ExpensesScreen({super.key, required this.tripId});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseViewModel>(
        context,
        listen: false,
      ).loadExpenses(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Expenses",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Color(0xFF7F3DFF),
              radius: 15,
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddExpenseScreen(tripId: widget.tripId),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ExpenseViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.expenses.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(viewModel.totalExpenses),
                const SizedBox(height: 20),
                const Text(
                  "Category Breakdown",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildCategoryBreakdown(viewModel),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${viewModel.expenses.length} items",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Transaction List
                _buildTransactionList(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSummaryCard(0.0),
          ),
          const SizedBox(height: 50),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.attach_money, size: 40, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const Text(
            "No expenses recorded",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddExpenseScreen(tripId: widget.tripId),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Add Your First Expense",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0077FF), Color(0xFF9933FF)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Expenses", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.attach_money, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ExpenseSummaryScreen(tripId: widget.tripId),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "View Summary & Reports",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(ExpenseViewModel viewModel) {
    final breakdown = viewModel.categoryBreakdown;
    final total = viewModel.totalExpenses;
    if (breakdown.isEmpty) return const SizedBox.shrink();

    IconData getIcon(String cat) {
      if (cat == 'Food') return Icons.fastfood;
      if (cat == 'Stay') return Icons.hotel;
      if (cat == 'Transport') return Icons.directions_car;
      return Icons.shopping_bag;
    }

    Color getColor(String cat) {
      if (cat == 'Food') return Colors.orange;
      if (cat == 'Stay') return Colors.red;
      if (cat == 'Transport') return Colors.blue;
      return Colors.purple;
    }

    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: breakdown.entries.map((entry) {
          final pct = total > 0 ? entry.value / total : 0.0;
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      getIcon(entry.key),
                      size: 18,
                      color: getColor(entry.key),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Text(
                  "\$${entry.value.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                LinearProgressIndicator(
                  value: pct,
                  backgroundColor: Colors.grey[200],
                  color: const Color(0xFF7F3DFF),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionList(ExpenseViewModel viewModel) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.expenses.length,
      itemBuilder: (context, index) {
        final expense = viewModel.expenses[index];

        IconData getIcon(String cat) {
          if (cat == 'Food') return Icons.fastfood;
          if (cat == 'Stay') return Icons.hotel;
          return Icons.shopping_bag;
        }

        Color getColor(String cat) {
          if (cat == 'Food') return Colors.orange;
          if (cat == 'Stay') return Colors.red;
          return Colors.purple;
        }

        // --- DISMISSIBLE FOR DELETE ---
        return Dismissible(
          key: Key(expense.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Delete Expense"),
                content: const Text(
                  "Are you sure you want to delete this expense?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            Provider.of<ExpenseViewModel>(
              context,
              listen: false,
            ).deleteExpense(expense.id, widget.tripId);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Expense deleted")));
          },
          // --- GESTURE DETECTOR FOR EDIT ---
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddExpenseScreen(
                    tripId: widget.tripId,
                    expenseToEdit: expense, // Pass expense to edit
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: getColor(expense.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      getIcon(expense.category),
                      color: getColor(expense.category),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.category,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          expense.note.isNotEmpty
                              ? expense.note
                              : DateFormat('MMM d').format(expense.date),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "\$${expense.amount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d').format(expense.date),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../viewmodels/expense_viewmodel.dart';
// import 'add_expense_screen.dart';
// import 'expense_summary_screen.dart'; // Import the new screen

// class ExpensesScreen extends StatefulWidget {
//   final String tripId;

//   const ExpensesScreen({super.key, required this.tripId});

//   @override
//   State<ExpensesScreen> createState() => _ExpensesScreenState();
// }

// class _ExpensesScreenState extends State<ExpensesScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ExpenseViewModel>(
//         context,
//         listen: false,
//       ).loadExpenses(widget.tripId);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Expenses",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: const CircleAvatar(
//               backgroundColor: Color(0xFF7F3DFF),
//               radius: 15,
//               child: Icon(Icons.add, color: Colors.white, size: 20),
//             ),
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => AddExpenseScreen(tripId: widget.tripId),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Consumer<ExpenseViewModel>(
//         builder: (context, viewModel, child) {
//           if (viewModel.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (viewModel.expenses.isEmpty) {
//             return _buildEmptyState();
//           }

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 1. Summary Card
//                 _buildSummaryCard(viewModel.totalExpenses),
//                 const SizedBox(height: 20),

//                 // 2. Category Breakdown
//                 const Text(
//                   "Category Breakdown",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 _buildCategoryBreakdown(viewModel),
//                 const SizedBox(height: 20),

//                 // 3. Recent Transactions
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       "Recent Transactions",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       "${viewModel.expenses.length} items",
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 _buildTransactionList(viewModel),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: _buildSummaryCard(0.0),
//           ),
//           const SizedBox(height: 50),
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(Icons.attach_money, size: 40, color: Colors.grey),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             "No expenses recorded",
//             style: TextStyle(color: Colors.grey, fontSize: 16),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => AddExpenseScreen(tripId: widget.tripId),
//               ),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.black,
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: const Text(
//               "Add Your First Expense",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryCard(double total) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF0077FF), Color(0xFF9933FF)],
//         ),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Total Expenses", style: TextStyle(color: Colors.white70)),
//           const SizedBox(height: 5),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "\$${total.toStringAsFixed(2)}",
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.attach_money, color: Colors.white),
//               ),
//             ],
//           ),
//           const SizedBox(height: 15),

//           // --- NAVIGATION TO SUMMARY SCREEN ---
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       ExpenseSummaryScreen(tripId: widget.tripId),
//                 ),
//               );
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.pie_chart_outline, color: Colors.white, size: 18),
//                   SizedBox(width: 8),
//                   Text(
//                     "View Summary & Reports",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryBreakdown(ExpenseViewModel viewModel) {
//     final breakdown = viewModel.categoryBreakdown;
//     final total = viewModel.totalExpenses;

//     if (breakdown.isEmpty) return const SizedBox.shrink();

//     IconData getIcon(String cat) {
//       if (cat == 'Food') return Icons.fastfood;
//       if (cat == 'Stay') return Icons.hotel;
//       if (cat == 'Transport') return Icons.directions_car;
//       return Icons.shopping_bag;
//     }

//     Color getColor(String cat) {
//       if (cat == 'Food') return Colors.orange;
//       if (cat == 'Stay') return Colors.red;
//       if (cat == 'Transport') return Colors.blue;
//       return Colors.purple;
//     }

//     return SizedBox(
//       height: 110,
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         children: breakdown.entries.map((entry) {
//           final pct = total > 0 ? entry.value / total : 0.0;
//           return Container(
//             width: 150,
//             margin: const EdgeInsets.only(right: 10),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       getIcon(entry.key),
//                       size: 18,
//                       color: getColor(entry.key),
//                     ),
//                     const SizedBox(width: 5),
//                     Text(
//                       entry.key,
//                       style: const TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   "\$${entry.value.toStringAsFixed(2)}",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 LinearProgressIndicator(
//                   value: pct,
//                   backgroundColor: Colors.grey[200],
//                   color: const Color(0xFF7F3DFF),
//                   minHeight: 6,
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildTransactionList(ExpenseViewModel viewModel) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: viewModel.expenses.length,
//       itemBuilder: (context, index) {
//         final expense = viewModel.expenses[index];

//         IconData getIcon(String cat) {
//           if (cat == 'Food') return Icons.fastfood;
//           if (cat == 'Stay') return Icons.hotel;
//           return Icons.shopping_bag;
//         }

//         Color getColor(String cat) {
//           if (cat == 'Food') return Colors.orange;
//           if (cat == 'Stay') return Colors.red;
//           return Colors.purple;
//         }

//         return Container(
//           margin: const EdgeInsets.only(bottom: 10),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: getColor(expense.category).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   getIcon(expense.category),
//                   color: getColor(expense.category),
//                 ),
//               ),
//               const SizedBox(width: 15),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       expense.category,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     Text(
//                       expense.note.isNotEmpty
//                           ? expense.note
//                           : DateFormat('MMM d').format(expense.date),
//                       style: const TextStyle(color: Colors.grey, fontSize: 13),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     "\$${expense.amount.toStringAsFixed(2)}",
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   Text(
//                     DateFormat('MMM d').format(expense.date),
//                     style: const TextStyle(color: Colors.grey, fontSize: 12),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

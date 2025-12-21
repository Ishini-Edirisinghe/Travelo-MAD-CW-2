import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/expense_entity.dart';
import '../viewmodels/expense_viewmodel.dart';

class AddExpenseScreen extends StatefulWidget {
  final String tripId;
  final ExpenseEntity? expenseToEdit; // Optional: If passed, we are editing

  const AddExpenseScreen({super.key, required this.tripId, this.expenseToEdit});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategory = "Food";
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Pre-fill data if editing
    if (widget.expenseToEdit != null) {
      final expense = widget.expenseToEdit!;
      _amountController.text = expense.amount.toString();
      _noteController.text = expense.note;
      _selectedCategory = expense.category;
      _selectedDate = expense.date;
    }
  }

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.fastfood, 'color': Colors.orange},
    {'name': 'Transport', 'icon': Icons.directions_car, 'color': Colors.blue},
    {'name': 'Stay', 'icon': Icons.hotel, 'color': Colors.red},
    {
      'name': 'Activities',
      'icon': Icons.local_activity,
      'color': Colors.purple,
    },
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.teal},
    {'name': 'Other', 'icon': Icons.category, 'color': Colors.grey},
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveExpense() async {
    final amountText = _amountController.text;
    if (amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final viewModel = Provider.of<ExpenseViewModel>(context, listen: false);

      if (widget.expenseToEdit == null) {
        // --- ADD MODE ---
        await viewModel.addExpense(
          tripId: widget.tripId,
          amount: amount,
          category: _selectedCategory,
          date: _selectedDate,
          note: _noteController.text,
        );
      } else {
        // --- EDIT MODE ---
        await viewModel.updateExpense(
          id: widget.expenseToEdit!.id, // Use existing ID
          tripId: widget.tripId,
          amount: amount,
          category: _selectedCategory,
          date: _selectedDate,
          note: _noteController.text,
        );
      }

      if (mounted) Navigator.pop(context); // Close loading
      if (mounted) Navigator.pop(context); // Close screen
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expenseToEdit != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit Expense" : "Add Expense",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Amount", isRequired: true),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: _inputDecoration("\$ 0.00"),
            ),
            const SizedBox(height: 24),
            _buildLabel("Category", isRequired: true),
            const SizedBox(height: 10),
            _buildCategoryGrid(),
            const SizedBox(height: 24),
            _buildLabel("Date"),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Text(DateFormat('MM/dd/yyyy').format(_selectedDate)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildLabel("Notes (Optional)"),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: _inputDecoration("Add any additional details...")
                  .copyWith(
                    prefixIcon: const Icon(
                      Icons.description_outlined,
                      color: Colors.grey,
                    ),
                  ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7F3DFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isEditing ? "Update Expense" : "Add Expense",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final isSelected = _selectedCategory == cat['name'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = cat['name'];
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEEE5FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF7F3DFF)
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat['icon'],
                  color: isSelected ? const Color(0xFF7F3DFF) : cat['color'],
                  size: 28,
                ),
                const SizedBox(height: 5),
                Text(
                  cat['name'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFF7F3DFF)
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: " *",
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF7F3DFF), width: 2),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../viewmodels/expense_viewmodel.dart';

// class AddExpenseScreen extends StatefulWidget {
//   final String tripId;

//   const AddExpenseScreen({super.key, required this.tripId});

//   @override
//   State<AddExpenseScreen> createState() => _AddExpenseScreenState();
// }

// class _AddExpenseScreenState extends State<AddExpenseScreen> {
//   final _amountController = TextEditingController();
//   final _noteController = TextEditingController();

//   String _selectedCategory = "Food";
//   DateTime _selectedDate = DateTime.now();

//   final List<Map<String, dynamic>> _categories = [
//     {'name': 'Food', 'icon': Icons.fastfood, 'color': Colors.orange},
//     {'name': 'Transport', 'icon': Icons.directions_car, 'color': Colors.blue},
//     {'name': 'Stay', 'icon': Icons.hotel, 'color': Colors.red},
//     {
//       'name': 'Activities',
//       'icon': Icons.local_activity,
//       'color': Colors.purple,
//     },
//     {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.teal},
//     {'name': 'Other', 'icon': Icons.category, 'color': Colors.grey},
//   ];

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   // --- UPDATED SAVE FUNCTION ---
//   Future<void> _saveExpense() async {
//     final amountText = _amountController.text;
//     if (amountText.isEmpty) return;

//     final amount = double.tryParse(amountText);
//     if (amount == null || amount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a valid amount")),
//       );
//       return;
//     }

//     // 1. Show Loading Indicator
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => const Center(child: CircularProgressIndicator()),
//     );

//     try {
//       // 2. Wait for ViewModel to add expense
//       await Provider.of<ExpenseViewModel>(context, listen: false).addExpense(
//         tripId: widget.tripId,
//         amount: amount,
//         category: _selectedCategory,
//         date: _selectedDate,
//         note: _noteController.text,
//       );

//       // 3. Close Loading Dialog
//       if (mounted) Navigator.pop(context);

//       // 4. Close Add Screen & Return to List
//       if (mounted) Navigator.pop(context);
//     } catch (e) {
//       // Close Loading Dialog if error
//       if (mounted) Navigator.pop(context);

//       // Show Error Message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error saving: $e"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           "Add Expense",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildLabel("Amount", isRequired: true),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _amountController,
//               keyboardType: const TextInputType.numberWithOptions(
//                 decimal: true,
//               ),
//               decoration: _inputDecoration("\$ 0.00"),
//             ),
//             const SizedBox(height: 24),
//             _buildLabel("Category", isRequired: true),
//             const SizedBox(height: 10),
//             _buildCategoryGrid(),
//             const SizedBox(height: 24),
//             _buildLabel("Date"),
//             const SizedBox(height: 10),
//             GestureDetector(
//               onTap: () => _selectDate(context),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 16,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF5F6FA),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(
//                       Icons.calendar_today_outlined,
//                       size: 20,
//                       color: Colors.grey,
//                     ),
//                     const SizedBox(width: 10),
//                     Text(DateFormat('MM/dd/yyyy').format(_selectedDate)),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             _buildLabel("Notes (Optional)"),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _noteController,
//               maxLines: 3,
//               decoration: _inputDecoration("Add any additional details...")
//                   .copyWith(
//                     prefixIcon: const Icon(
//                       Icons.description_outlined,
//                       color: Colors.grey,
//                     ),
//                   ),
//             ),
//             const SizedBox(height: 40),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       side: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     child: const Text(
//                       "Cancel",
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _saveExpense,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF7F3DFF),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       "Add Expense",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryGrid() {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         childAspectRatio: 1.2,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemCount: _categories.length,
//       itemBuilder: (context, index) {
//         final cat = _categories[index];
//         final isSelected = _selectedCategory == cat['name'];
//         return GestureDetector(
//           onTap: () {
//             setState(() {
//               _selectedCategory = cat['name'];
//             });
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               color: isSelected ? const Color(0xFFEEE5FF) : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: isSelected
//                     ? const Color(0xFF7F3DFF)
//                     : Colors.grey.shade300,
//                 width: isSelected ? 2 : 1,
//               ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   cat['icon'],
//                   color: isSelected ? const Color(0xFF7F3DFF) : cat['color'],
//                   size: 28,
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   cat['name'],
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: isSelected
//                         ? FontWeight.bold
//                         : FontWeight.normal,
//                     color: isSelected
//                         ? const Color(0xFF7F3DFF)
//                         : Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildLabel(String text, {bool isRequired = false}) {
//     return RichText(
//       text: TextSpan(
//         text: text,
//         style: const TextStyle(
//           color: Colors.black87,
//           fontWeight: FontWeight.w600,
//           fontSize: 16,
//         ),
//         children: [
//           if (isRequired)
//             const TextSpan(
//               text: " *",
//               style: TextStyle(color: Colors.red),
//             ),
//         ],
//       ),
//     );
//   }

//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       filled: true,
//       fillColor: const Color(0xFFF5F6FA),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFF7F3DFF), width: 2),
//       ),
//     );
//   }
// }

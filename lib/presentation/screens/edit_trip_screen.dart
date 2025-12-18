import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/trip_entity.dart';

class EditTripScreen extends StatefulWidget {
  final TripEntity trip;

  const EditTripScreen({super.key, required this.trip});

  @override
  State<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _destinationController;
  late TextEditingController _descriptionController;

  // State Variables
  late DateTime _startDate;
  late DateTime _endDate;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController(text: widget.trip.title);
    _descriptionController = TextEditingController(
      text: widget.trip.description,
    );
    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
    _imagePath = widget.trip.imagePath;
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Edit Trip",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              const Text(
                "Cover Image",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[200],
                        image: _imagePath != null
                            ? DecorationImage(
                                image: FileImage(File(_imagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _imagePath == null
                          ? const Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.photo_library_outlined,
                          size: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _buildLabel("Destination", isRequired: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _destinationController,
                decoration: _inputDecoration("Enter destination"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter a destination" : null,
              ),

              const SizedBox(height: 24),
              // Dates
              Row(
                children: [
                  Expanded(
                    child: _buildDateSelector("Start Date", _startDate, true),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateSelector("End Date", _endDate, false),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildLabel("Description"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _inputDecoration("Enter description").copyWith(
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, top: 12),
                    child: Icon(
                      Icons.description_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final updatedTrip = TripEntity(
                        id: widget.trip.id, // CRITICAL: Keep original ID
                        title: _destinationController.text,
                        startDate: _startDate,
                        endDate: _endDate,
                        description: _descriptionController.text,
                        imagePath: _imagePath,
                      );
                      Navigator.pop(context, updatedTrip);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7F3DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Update Trip",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime date, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: true),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context, isStart),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(DateFormat('MM/dd/yyyy').format(date)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF2D3142),
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
      prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
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

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../domain/entities/trip_entity.dart';

// class EditTripScreen extends StatefulWidget {
//   final TripEntity trip;

//   const EditTripScreen({super.key, required this.trip});

//   @override
//   State<EditTripScreen> createState() => _EditTripScreenState();
// }

// class _EditTripScreenState extends State<EditTripScreen> {
//   final _formKey = GlobalKey<FormState>();

//   // Controllers
//   late TextEditingController _destinationController;
//   late TextEditingController _descriptionController;

//   // State Variables
//   late DateTime _startDate;
//   late DateTime _endDate;
//   String? _imagePath;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize with existing data
//     _destinationController = TextEditingController(text: widget.trip.title);
//     _descriptionController = TextEditingController(
//       text: widget.trip.description,
//     );
//     _startDate = widget.trip.startDate;
//     _endDate = widget.trip.endDate;
//     _imagePath = widget.trip.imagePath;
//   }

//   @override
//   void dispose() {
//     _destinationController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   // Pick Image Function
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _imagePath = pickedFile.path;
//       });
//     }
//   }

//   // Date Picker Function
//   Future<void> _selectDate(BuildContext context, bool isStart) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: isStart ? _startDate : _endDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );

//     if (picked != null) {
//       setState(() {
//         if (isStart) {
//           _startDate = picked;
//           // Ensure end date is not before start date
//           if (_endDate.isBefore(_startDate)) {
//             _endDate = _startDate.add(const Duration(days: 1));
//           }
//         } else {
//           _endDate = picked;
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           "Edit Trip",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 1. Cover Image Section
//               const Text(
//                 "Cover Image",
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black54,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: Stack(
//                   children: [
//                     Container(
//                       height: 200,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(16),
//                         color: Colors.grey[200],
//                         image: _imagePath != null
//                             ? DecorationImage(
//                                 image: FileImage(File(_imagePath!)),
//                                 fit: BoxFit.cover,
//                               )
//                             : null,
//                       ),
//                       child: _imagePath == null
//                           ? const Center(
//                               child: Icon(
//                                 Icons.image,
//                                 size: 50,
//                                 color: Colors.grey,
//                               ),
//                             )
//                           : null,
//                     ),
//                     // Gallery Icon Button
//                     Positioned(
//                       bottom: 12,
//                       right: 12,
//                       child: Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: const BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.photo_library_outlined,
//                           size: 20,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // 2. Destination Input
//               _buildLabel("Destination", isRequired: true),
//               const SizedBox(height: 8),
//               TextFormField(
//                 controller: _destinationController,
//                 decoration: _inputDecoration("Enter destination"),
//                 validator: (value) =>
//                     value!.isEmpty ? "Please enter a destination" : null,
//               ),

//               const SizedBox(height: 24),

//               // 3. Date Selection Row
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildLabel("Start Date", isRequired: true),
//                         const SizedBox(height: 8),
//                         GestureDetector(
//                           onTap: () => _selectDate(context, true),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 15,
//                             ),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFF5F6FA),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: Colors.grey.shade300),
//                             ),
//                             child: Row(
//                               children: [
//                                 const Icon(
//                                   Icons.calendar_today_outlined,
//                                   size: 18,
//                                   color: Colors.grey,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   DateFormat('MM/dd/yyyy').format(_startDate),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildLabel("End Date", isRequired: true),
//                         const SizedBox(height: 8),
//                         GestureDetector(
//                           onTap: () => _selectDate(context, false),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 15,
//                             ),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFF5F6FA),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: Colors.grey.shade300),
//                             ),
//                             child: Row(
//                               children: [
//                                 const Icon(
//                                   Icons.calendar_today_outlined,
//                                   size: 18,
//                                   color: Colors.grey,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(DateFormat('MM/dd/yyyy').format(_endDate)),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 24),

//               // 4. Description Input
//               _buildLabel("Description"),
//               const SizedBox(height: 8),
//               TextFormField(
//                 controller: _descriptionController,
//                 maxLines: 4,
//                 decoration: _inputDecoration("Enter description").copyWith(
//                   contentPadding: const EdgeInsets.all(16),
//                   prefixIcon: const Padding(
//                     padding: EdgeInsets.only(left: 12, top: 12),
//                     child: Align(
//                       alignment: Alignment.topLeft,
//                       widthFactor: 1.0,
//                       heightFactor: 5.0,
//                       child: Icon(
//                         Icons.description_outlined,
//                         size: 20,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 40),

//               // 5. Update Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       // Create updated trip object
//                       final updatedTrip = TripEntity(
//                         // Assuming TripEntity has an ID, pass it here if needed
//                         title: _destinationController.text,
//                         startDate: _startDate,
//                         endDate: _endDate,
//                         description: _descriptionController.text,
//                         imagePath: _imagePath,
//                         id: '',
//                         // Add any other required fields from your entity
//                       );

//                       // Return the updated trip to the previous screen
//                       Navigator.pop(context, updatedTrip);
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(
//                       0xFF7F3DFF,
//                     ), // Purple from design
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: const Text(
//                     "Update Trip",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper: Label Builder
//   Widget _buildLabel(String text, {bool isRequired = false}) {
//     return RichText(
//       text: TextSpan(
//         text: text,
//         style: const TextStyle(
//           color: Color(0xFF2D3142),
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

//   // Helper: Input Decoration
//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       filled: true,
//       fillColor: const Color(0xFFF5F6FA),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
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

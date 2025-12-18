import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_gradient_button.dart';
import '../../domain/entities/trip_entity.dart';
import '../viewmodels/trip_viewmodel.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  File? _selectedImage;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6A5AE0),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text =
              "${picked.month}/${picked.day}/${picked.year}";
        } else {
          _endDate = picked;
          _endDateController.text =
              "${picked.month}/${picked.day}/${picked.year}";
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Helper Widget for Labels
  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: " *",
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Text Fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Create New Trip",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cover Image",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : const Center(
                        child: Icon(Icons.add_a_photo, color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(height: 25),

            _buildLabel("Destination", isRequired: true),
            _buildTextField(
              controller: _destinationController,
              hint: "Where to?",
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Start Date", isRequired: true),
                      GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: AbsorbPointer(
                          child: _buildTextField(
                            controller: _startDateController,
                            hint: "Select Date",
                            icon: Icons.calendar_today_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("End Date", isRequired: true),
                      GestureDetector(
                        onTap: () => _selectDate(context, false),
                        child: AbsorbPointer(
                          child: _buildTextField(
                            controller: _endDateController,
                            hint: "Select Date",
                            icon: Icons.calendar_today_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            _buildLabel("Description"),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Trip details...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
            ),

            const SizedBox(height: 40),

            CustomGradientButton(
              text: "Create Trip",
              onPressed: () {
                if (_destinationController.text.isEmpty ||
                    _startDate == null ||
                    _endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Fill required fields")),
                  );
                  return;
                }

                // 1. Create the Trip Object
                final newTrip = TripEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _destinationController.text,
                  startDate: _startDate!,
                  endDate: _endDate!,
                  description: _descriptionController.text,
                  imagePath: _selectedImage?.path,
                );

                // 2. Save via Provider
                Provider.of<TripViewModel>(
                  context,
                  listen: false,
                ).addTrip(newTrip);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Trip Created Successfully!")),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
// import 'dart:io'; // Required for File handling
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart'; // Required for picking images
// import '../widgets/custom_gradient_button.dart'; // Import the new button

// class CreateTripScreen extends StatefulWidget {
//   const CreateTripScreen({super.key});

//   @override
//   State<CreateTripScreen> createState() => _CreateTripScreenState();
// }

// class _CreateTripScreenState extends State<CreateTripScreen> {
//   // Controllers
//   final TextEditingController _destinationController = TextEditingController();
//   final TextEditingController _startDateController = TextEditingController();
//   final TextEditingController _endDateController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();

//   DateTime? _startDate;
//   DateTime? _endDate;
//   File? _selectedImage; // Variable to store the picked image

//   // Function to pick date
//   Future<void> _selectDate(BuildContext context, bool isStart) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFF6A5AE0),
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         if (isStart) {
//           _startDate = picked;
//           _startDateController.text =
//               "${picked.month}/${picked.day}/${picked.year}";
//         } else {
//           _endDate = picked;
//           _endDateController.text =
//               "${picked.month}/${picked.day}/${picked.year}";
//         }
//       });
//     }
//   }

//   // Function to pick image from gallery
//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);

//     if (image != null) {
//       setState(() {
//         _selectedImage = File(image.path);
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
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Create New Trip",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 1. Cover Image Section (Clickable)
//             const Text(
//               "Cover Image",
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             ),
//             const SizedBox(height: 10),

//             GestureDetector(
//               onTap: _pickImage, // Opens Gallery on tap
//               child: Container(
//                 height: 180,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(20),
//                   image: DecorationImage(
//                     image: _selectedImage != null
//                         ? FileImage(_selectedImage!)
//                               as ImageProvider // Show picked image
//                         : const NetworkImage(
//                             // Show placeholder
//                             'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?q=80&w=1000&auto=format&fit=crop',
//                           ),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 child: Stack(
//                   children: [
//                     // Dark Overlay
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: Colors.black.withOpacity(0.2),
//                       ),
//                     ),
//                     // Camera Icon Button
//                     Positioned(
//                       bottom: 15,
//                       right: 15,
//                       child: Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: const BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(color: Colors.black26, blurRadius: 5),
//                           ],
//                         ),
//                         child: const Icon(
//                           Icons.image_outlined,
//                           color: Color(0xFF6A5AE0),
//                           size: 22,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 25),

//             // 2. Destination Input
//             _buildLabel("Destination", isRequired: true),
//             _buildTextField(
//               controller: _destinationController,
//               hint: "Where are you going?",
//               icon: Icons.location_on_outlined,
//             ),

//             const SizedBox(height: 20),

//             // 3. Date Pickers Row
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildLabel("Start Date", isRequired: true),
//                       GestureDetector(
//                         onTap: () => _selectDate(context, true),
//                         child: AbsorbPointer(
//                           child: _buildTextField(
//                             controller: _startDateController,
//                             hint: "mm/dd/yyyy",
//                             icon: Icons.calendar_today_outlined,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 15),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildLabel("End Date", isRequired: true),
//                       GestureDetector(
//                         onTap: () => _selectDate(context, false),
//                         child: AbsorbPointer(
//                           child: _buildTextField(
//                             controller: _endDateController,
//                             hint: "mm/dd/yyyy",
//                             icon: Icons.calendar_today_outlined,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // 4. Description Input
//             _buildLabel("Description"),
//             Container(
//               height: 120,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F6FA),
//                 borderRadius: BorderRadius.circular(15),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: TextField(
//                 controller: _descriptionController,
//                 maxLines: 5,
//                 decoration: const InputDecoration(
//                   hintText: "Tell us about your trip...",
//                   hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
//                   prefixIcon: Padding(
//                     padding: EdgeInsets.only(
//                       left: 0,
//                       bottom: 75,
//                     ), // Align icon to top
//                     child: Icon(Icons.description_outlined, color: Colors.grey),
//                   ),
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.symmetric(
//                     horizontal: 15,
//                     vertical: 15,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 40),

//             // 5. Create Button (Using Custom Gradient Widget)
//             CustomGradientButton(
//               text: "Create Trip",
//               onPressed: () {
//                 // Validate
//                 if (_destinationController.text.isEmpty ||
//                     _startDateController.text.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("Please fill in required fields"),
//                     ),
//                   );
//                   return;
//                 }

//                 // Success Action
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Trip Created Successfully!")),
//                 );
//                 Navigator.pop(context);
//               },
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper Widget for Labels
//   Widget _buildLabel(String text, {bool isRequired = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8, left: 2),
//       child: RichText(
//         text: TextSpan(
//           text: text,
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//             color: Colors.black87,
//           ),
//           children: [
//             if (isRequired)
//               const TextSpan(
//                 text: " *",
//                 style: TextStyle(color: Colors.red),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper Widget for Text Fields
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFF5F6FA),
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: TextField(
//         controller: controller,
//         style: const TextStyle(fontSize: 14),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
//           prefixIcon: Icon(icon, color: Colors.grey, size: 20),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(vertical: 15),
//         ),
//       ),
//     );
//   }
// }

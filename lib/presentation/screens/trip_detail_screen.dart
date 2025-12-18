import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/trip_entity.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/repositories/trip_repository_impl.dart';
import 'edit_trip_screen.dart';
import '../../presentation/viewmodels/trip_viewmodel.dart'; // Adjust path if needed

class TripDetailScreen extends StatefulWidget {
  final TripEntity trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late TripEntity _currentTrip;

  @override
  void initState() {
    super.initState();
    _currentTrip = widget.trip;
  }

  Future<void> _handleEditTrip(BuildContext context) async {
    // 1. Navigate to Edit Screen
    final updatedTrip = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTripScreen(trip: _currentTrip),
      ),
    );

    // 2. Check result
    if (updatedTrip != null && updatedTrip is TripEntity) {
      try {
        // A. Update Database
        final repository = TripRepositoryImpl(LocalDataSource());
        await repository.updateTrip(updatedTrip);

        // B. Update Local UI (Detail Screen)
        setState(() {
          _currentTrip = updatedTrip;
        });

        // C. Update Global State (Home/List Screen)
        // This ensures the list screen gets the new data immediately
        if (mounted) {
          Provider.of<TripViewModel>(context, listen: false).loadTrips();
        }

        // D. Success Message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating trip: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate Duration using _currentTrip (so it updates dynamically)
    final daysCount =
        _currentTrip.endDate.difference(_currentTrip.startDate).inDays + 1;
    final dateRange =
        "${DateFormat('MMM d').format(_currentTrip.startDate)} - ${DateFormat('MMM d, yyyy').format(_currentTrip.endDate)}";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // A. Cover Image
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child:
                      _currentTrip.imagePath != null &&
                          _currentTrip.imagePath!.isNotEmpty
                      ? Image.file(
                          File(_currentTrip.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) =>
                              Container(color: Colors.grey[300]),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                ),

                // B. Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),

                // C. Navigation Bar
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCircleButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context), // Go back to list
                      ),
                      _buildCircleButton(
                        icon: Icons.edit_outlined,
                        onTap: () => _handleEditTrip(context), // Trigger Edit
                      ),
                    ],
                  ),
                ),

                // D. Title & Date
                Positioned(
                  bottom: 80,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentTrip.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black45,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dateRange,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "$daysCount Days Trip",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            // Description Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentTrip.description.isNotEmpty
                        ? _currentTrip.description
                        : "No description provided.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.4,
                    children: [
                      _buildActionCard(
                        icon: Icons.book,
                        title: "Journals",
                        subtitle: "0 entries",
                        color: const Color(0xFF2D9CDB),
                        onTap: () {},
                      ),
                      _buildActionCard(
                        icon: Icons.attach_money,
                        title: "Expenses",
                        subtitle: "\$0 spent",
                        color: const Color(0xFF9B51E0),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helpers
  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../domain/entities/trip_entity.dart';
// import '../../data/datasources/local_datasource.dart';
// import '../../data/repositories/trip_repository_impl.dart';
// import 'edit_trip_screen.dart';

// class TripDetailScreen extends StatefulWidget {
//   final TripEntity trip;

//   const TripDetailScreen({super.key, required this.trip});

//   @override
//   State<TripDetailScreen> createState() => _TripDetailScreenState();
// }

// class _TripDetailScreenState extends State<TripDetailScreen> {
//   late TripEntity _currentTrip;

//   @override
//   void initState() {
//     super.initState();
//     _currentTrip = widget.trip;
//   }

//   Future<void> _handleEditTrip(BuildContext context) async {
//     // Navigate to Edit Screen
//     final updatedTrip = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditTripScreen(trip: _currentTrip),
//       ),
//     );

//     if (updatedTrip != null && updatedTrip is TripEntity) {
//       try {
//         // 1. Update Database
//         // FIX: Pass LocalDataSource() directly inside the parenthesis
//         final repository = TripRepositoryImpl(LocalDataSource());

//         await repository.updateTrip(updatedTrip);

//         // 2. Update UI
//         setState(() {
//           _currentTrip = updatedTrip;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Trip updated successfully!')),
//         );
//       } catch (e) {
//         print("Error: $e"); // Debug print
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error updating trip: $e')));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Calculate Duration
//     final daysCount =
//         _currentTrip.endDate.difference(_currentTrip.startDate).inDays + 1;
//     final dateRange =
//         "${DateFormat('MMM d').format(_currentTrip.startDate)} - ${DateFormat('MMM d, yyyy').format(_currentTrip.endDate)}";

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 SizedBox(
//                   height: 320,
//                   width: double.infinity,
//                   child:
//                       _currentTrip.imagePath != null &&
//                           _currentTrip.imagePath!.isNotEmpty
//                       ? Image.file(
//                           File(_currentTrip.imagePath!),
//                           fit: BoxFit.cover,
//                         )
//                       : Container(
//                           color: Colors.grey[300],
//                           child: const Icon(
//                             Icons.image,
//                             size: 50,
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//                 Positioned.fill(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.black.withOpacity(0.3),
//                           Colors.transparent,
//                           Colors.black.withOpacity(0.8),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 50,
//                   left: 20,
//                   right: 20,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _buildCircleButton(
//                         icon: Icons.arrow_back,
//                         onTap: () => Navigator.pop(context),
//                       ),
//                       // Edit Button calling the handler
//                       _buildCircleButton(
//                         icon: Icons.edit_outlined,
//                         onTap: () => _handleEditTrip(context),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 80,
//                   left: 20,
//                   right: 20,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         _currentTrip.title,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           shadows: [
//                             Shadow(
//                               blurRadius: 10,
//                               color: Colors.black45,
//                               offset: Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.calendar_today,
//                             color: Colors.white70,
//                             size: 16,
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             dateRange,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           "$daysCount Days Trip",
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 35),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _currentTrip.description.isNotEmpty
//                         ? _currentTrip.description
//                         : "No description provided.",
//                     style: TextStyle(
//                       fontSize: 15,
//                       height: 1.5,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   const Text(
//                     "Quick Actions",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   GridView.count(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     crossAxisCount: 2,
//                     mainAxisSpacing: 15,
//                     crossAxisSpacing: 15,
//                     childAspectRatio: 1.4,
//                     children: [
//                       _buildActionCard(
//                         icon: Icons.book,
//                         title: "Journals",
//                         subtitle: "0 entries",
//                         color: const Color(0xFF2D9CDB),
//                         onTap: () {},
//                       ),
//                       _buildActionCard(
//                         icon: Icons.attach_money,
//                         title: "Expenses",
//                         subtitle: "\$0 spent",
//                         color: const Color(0xFF9B51E0),
//                         onTap: () {},
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCircleButton({
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.2),
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
//         ),
//         child: Icon(icon, color: Colors.white, size: 22),
//       ),
//     );
//   }

//   Widget _buildActionCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.4),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Icon(icon, color: Colors.white, size: 28),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: const TextStyle(color: Colors.white70, fontSize: 12),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

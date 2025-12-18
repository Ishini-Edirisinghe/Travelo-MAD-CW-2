import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/trip_entity.dart';

class TripDetailScreen extends StatelessWidget {
  final TripEntity trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    // Calculate Duration
    final daysCount = trip.endDate.difference(trip.startDate).inDays + 1;
    final dateRange =
        "${DateFormat('MMM d').format(trip.startDate)} - ${DateFormat('MMM d, yyyy').format(trip.endDate)}";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Light gray background
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==============================
            // 1. HEADER SECTION & STATS
            // ==============================
            Stack(
              clipBehavior: Clip.none,
              children: [
                // A. Cover Image
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: trip.imagePath != null && trip.imagePath!.isNotEmpty
                      ? Image.file(
                          File(trip.imagePath!),
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

                // C. Top Navigation Bar (Back & Edit)
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      _buildCircleButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                      ),
                      // Edit Button (Share removed)
                      _buildCircleButton(
                        icon: Icons.edit_outlined,
                        onTap: () {
                          // TODO: Implement Edit Trip functionality
                        },
                      ),
                    ],
                  ),
                ),

                // D. Title & Date Information (On Image)
                Positioned(
                  bottom: 80,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title,
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

                      // Date Range
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

                      // Days Count (Under Date Range)
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

            // ==============================
            // 2. DESCRIPTION & CONTENT
            // ==============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.description.isNotEmpty
                        ? trip.description
                        : "No description provided.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==============================
                  // 3. QUICK ACTIONS GRID (Only 2 Items)
                  // ==============================
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
                      // Journals (Blue)
                      _buildActionCard(
                        icon: Icons.book,
                        title: "Journals",
                        subtitle: "0 entries",
                        color: const Color(0xFF2D9CDB), // Blue
                        onTap: () {
                          // Navigate to Journals Screen
                        },
                      ),

                      // Expenses (Purple)
                      _buildActionCard(
                        icon: Icons.attach_money,
                        title: "Expenses",
                        subtitle: "\$0 spent",
                        color: const Color(0xFF9B51E0), // Purple
                        onTap: () {
                          // Navigate to Expenses Screen
                        },
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

  // --- WIDGET HELPERS ---

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2), // Glass effect
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
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

// class TripDetailScreen extends StatelessWidget {
//   final TripEntity trip;

//   const TripDetailScreen({super.key, required this.trip});

//   @override
//   Widget build(BuildContext context) {
//     // Calculate Duration
//     final daysCount = trip.endDate.difference(trip.startDate).inDays + 1;
//     final dateRange =
//         "${DateFormat('MMM d').format(trip.startDate)} - ${DateFormat('MMM d, yyyy').format(trip.endDate)}";

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA), // Light gray background
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ==============================
//             // 1. HEADER SECTION & STATS
//             // ==============================
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 // A. Cover Image
//                 SizedBox(
//                   height: 320,
//                   width: double.infinity,
//                   child: trip.imagePath != null && trip.imagePath!.isNotEmpty
//                       ? Image.file(
//                           File(trip.imagePath!),
//                           fit: BoxFit.cover,
//                           errorBuilder: (ctx, err, stack) =>
//                               Container(color: Colors.grey[300]),
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

//                 // B. Gradient Overlay
//                 Positioned.fill(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.black.withOpacity(0.3),
//                           Colors.transparent,
//                           Colors.black.withOpacity(0.7),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//                 // C. Top Navigation Bar (Back, Edit, Share)
//                 Positioned(
//                   top: 50,
//                   left: 20,
//                   right: 20,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Back Button
//                       _buildCircleButton(
//                         icon: Icons.arrow_back,
//                         onTap: () => Navigator.pop(context),
//                       ),
//                       // Actions Row
//                       Row(
//                         children: [
//                           _buildCircleButton(
//                             icon: Icons.edit_outlined,
//                             onTap: () {},
//                           ),
//                           const SizedBox(width: 15),
//                           _buildCircleButton(
//                             icon: Icons.share_outlined,
//                             onTap: () {},
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 // D. Title & Date (On Image)
//                 Positioned(
//                   bottom: 80, // Moved up to make room for floating card
//                   left: 20,
//                   right: 20,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         trip.title,
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
//                       const SizedBox(height: 6),
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
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 35), // Spacing for the overlapping card
//             // ==============================
//             // 2. DESCRIPTION & CONTENT
//             // ==============================
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     trip.description.isNotEmpty
//                         ? trip.description
//                         : "No description provided.",
//                     style: TextStyle(
//                       fontSize: 15,
//                       height: 1.5,
//                       color: Colors.grey[600],
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   // ==============================
//                   // 3. QUICK ACTIONS GRID
//                   // ==============================
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
//                     childAspectRatio: 1.4, // Width/Height ratio
//                     children: [
//                       // Journals (Blue)
//                       _buildActionCard(
//                         icon: Icons.book,
//                         title: "Journals",
//                         subtitle: "0 entries",
//                         color: const Color(0xFF2D9CDB), // Blue
//                         onTap: () {
//                           // Navigate to Journals Screen
//                         },
//                       ),
//                       // Gallery (Purple)
//                       _buildActionCard(
//                         icon: Icons.camera_alt_outlined,
//                         title: "Gallery",
//                         subtitle: "0 photos",
//                         color: const Color(0xFF9B51E0), // Purple
//                         onTap: () {},
//                       ),
//                       // Locations (Green)
//                       _buildActionCard(
//                         icon: Icons.location_on_outlined,
//                         title: "Locations",
//                         subtitle: "1 places",
//                         color: const Color(0xFF00C853), // Green
//                         onTap: () {},
//                       ),
//                       // Expenses (Orange)
//                       _buildActionCard(
//                         icon: Icons.attach_money,
//                         title: "Expenses",
//                         subtitle: "\$0 spent",
//                         color: const Color(0xFFFF6D00), // Orange
//                         onTap: () {
//                           // Navigate to Expenses Screen
//                         },
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 30), // Bottom padding
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- WIDGET HELPERS ---

//   Widget _buildCircleButton({
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.2), // Glass effect
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
//         ),
//         child: Icon(icon, color: Colors.white, size: 22),
//       ),
//     );
//   }

//   Widget _buildStatItem(
//     IconData icon,
//     String label,
//     String value,
//     Color color,
//   ) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, size: 20, color: color),
//         ),
//         const SizedBox(height: 8),
//         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//       ],
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
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../domain/entities/trip_entity.dart';

// class TripDetailScreen extends StatelessWidget {
//   final TripEntity trip;

//   const TripDetailScreen({super.key, required this.trip});

//   @override
//   Widget build(BuildContext context) {
//     // Calculate Duration
//     final daysCount = trip.endDate.difference(trip.startDate).inDays + 1;
//     final dateRange =
//         "${DateFormat('MMMM d').format(trip.startDate)} - ${DateFormat('MMMM d, yyyy').format(trip.endDate)}";

//     return Scaffold(
//       backgroundColor: Colors.white,
//       extendBodyBehindAppBar: true, // Allows image to go behind the back button
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: Container(
//           margin: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.3),
//             shape: BoxShape.circle,
//           ),
//           child: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ==============================
//             // 1. HEADER SECTION (Image & Title)
//             // ==============================
//             Stack(
//               children: [
//                 // Background Image
//                 SizedBox(
//                   height: 300,
//                   width: double.infinity,
//                   child: trip.imagePath != null && trip.imagePath!.isNotEmpty
//                       ? Image.file(
//                           File(trip.imagePath!),
//                           fit: BoxFit.cover,
//                           errorBuilder: (ctx, err, stack) =>
//                               Container(color: Colors.grey[300]),
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
//                 // Gradient Overlay
//                 Positioned.fill(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.transparent,
//                           Colors.black.withOpacity(0.1),
//                           Colors.black.withOpacity(0.8),
//                         ],
//                         stops: const [0.4, 0.7, 1.0],
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Text Content (Bottom Left)
//                 Positioned(
//                   bottom: 20,
//                   left: 20,
//                   right: 20,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         trip.title,
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
//                       Text(
//                         dateRange,
//                         style: const TextStyle(
//                           color: Colors.white70,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         "$daysCount days • 0 entries • 0 photos", // Placeholder stats
//                         style: const TextStyle(
//                           color: Colors.white70,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             // ==============================
//             // 2. GRID MENU SECTION
//             // ==============================
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Trip Management",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Grid Layout
//                   GridView.count(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     crossAxisCount: 2,
//                     mainAxisSpacing: 15,
//                     crossAxisSpacing: 15,
//                     childAspectRatio: 1.1, // Adjusts height of cards
//                     children: [
//                       _buildMenuCard(
//                         icon: Icons.book,
//                         label: "Daily Journal",
//                         color: Colors.blue.shade50,
//                         iconColor: Colors.blue,
//                         onTap: () {
//                           // Navigate to Journal
//                         },
//                       ),
//                       _buildMenuCard(
//                         icon: Icons.photo_library,
//                         label: "Photo Gallery",
//                         color: Colors.purple.shade50,
//                         iconColor: Colors.purple,
//                         onTap: () {},
//                       ),
//                       _buildMenuCard(
//                         icon: Icons.map,
//                         label: "Location & Map",
//                         color: Colors.green.shade50,
//                         iconColor: Colors.green,
//                         onTap: () {},
//                       ),
//                       _buildMenuCard(
//                         icon: Icons.access_time,
//                         label: "Travel Timeline",
//                         color: Colors.orange.shade50,
//                         iconColor: Colors.orange,
//                         onTap: () {},
//                       ),
//                       _buildMenuCard(
//                         icon: Icons.attach_money,
//                         label: "Expense Tracking",
//                         color: Colors.red.shade50,
//                         iconColor: Colors.red,
//                         onTap: () {},
//                       ),
//                       _buildMenuCard(
//                         icon: Icons.favorite_border,
//                         label: "Lifestyle Tracking",
//                         color: Colors.pink.shade50,
//                         iconColor: Colors.pink,
//                         onTap: () {},
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMenuCard({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required Color iconColor,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Colors.grey.shade100),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.03),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: color, // Pastel background
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Icon(icon, color: iconColor, size: 28),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/trip_viewmodel.dart';
import '../widgets/trip_card.dart';
import 'trip_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure we have the latest data when opening this tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripViewModel>(context, listen: false).loadTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Saved Trips",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Hide back button for tab
      ),
      body: Consumer<TripViewModel>(
        builder: (context, viewModel, child) {
          // Filter the list to get only favorites
          final favoriteTrips = viewModel.favoriteTrips;

          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favoriteTrips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 60,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No favorite trips yet",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: favoriteTrips.length,
            itemBuilder: (context, index) {
              final trip = favoriteTrips[index];
              final dateRange =
                  "${DateFormat('MMM d').format(trip.startDate)} - ${DateFormat('MMM d, yyyy').format(trip.endDate)}";
              final days = trip.endDate.difference(trip.startDate).inDays + 1;

              return TripCard(
                title: trip.title,
                date: dateRange,
                description: trip.description,
                imageUrl: trip.imagePath,
                placesCount: 0,
                daysCount: days,
                isFavorite: true, // It's in the favorites list, so it's true
                onFavoriteTap: () {
                  // Tapping this on the Favorites screen will REMOVE it from the list
                  viewModel.toggleFavorite(trip);
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TripDetailScreen(trip: trip),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../viewmodels/trip_viewmodel.dart';
// import '../widgets/trip_card.dart';
// import 'trip_detail_screen.dart';

// class FavoritesScreen extends StatelessWidget {
//   const FavoritesScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           "Favorites",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Consumer<TripViewModel>(
//         builder: (context, viewModel, child) {
//           // Use the getter we created in the ViewModel
//           final favoriteTrips = viewModel.favoriteTrips;

//           if (viewModel.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (favoriteTrips.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.favorite_border,
//                       size: 50,
//                       color: Colors.grey[400],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     "No favorites yet",
//                     style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(20),
//             itemCount: favoriteTrips.length,
//             itemBuilder: (context, index) {
//               final trip = favoriteTrips[index];
//               final dateRange =
//                   "${DateFormat('MMM d').format(trip.startDate)} - ${DateFormat('MMM d, yyyy').format(trip.endDate)}";
//               final days = trip.endDate.difference(trip.startDate).inDays + 1;

//               return TripCard(
//                 title: trip.title,
//                 date: dateRange,
//                 description: trip.description,
//                 imageUrl: trip.imagePath,
//                 placesCount: 0,
//                 daysCount: days,
//                 isFavorite: trip.isFavorite,
//                 onFavoriteTap: () {
//                   // Toggle favorite status
//                   viewModel.toggleFavorite(trip);
//                 },
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => TripDetailScreen(trip: trip),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/trip_viewmodel.dart';
import '../widgets/trip_card.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "My Trips",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<TripViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.trips.isEmpty) {
            return const Center(child: Text("No trips yet. Create one!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: viewModel.trips.length,
            itemBuilder: (context, index) {
              final trip = viewModel.trips[index];
              final dateRange =
                  "${DateFormat('MMM d').format(trip.startDate)} - ${DateFormat('MMM d, yyyy').format(trip.endDate)}";
              final days = trip.endDate.difference(trip.startDate).inDays + 1;

              return Dismissible(
                key: Key(trip.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  viewModel.deleteTrip(trip.id);
                },
                child: TripCard(
                  title: trip.title,
                  date: dateRange,
                  description: trip.description,
                  imageUrl: trip.imagePath,
                  placesCount: 0,
                  daysCount: days,
                  onTap: () {
                    // Navigate to details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../widgets/trip_card.dart';

// class TripsScreen extends StatelessWidget {
//   const TripsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "My Trips",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: false,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           // Example Trip 1
//           TripCard(
//             title: "Bali, Indonesia",
//             date: "Dec 20 - Dec 27, 2024",
//             description: "A week of paradise beaches and cultural exploration.",
//             imageUrl: "", // Add image URL here
//             placesCount: 5,
//             daysCount: 7,
//             onTap: () {},
//           ),
//           // Example Trip 2
//           TripCard(
//             title: "Paris, France",
//             date: "Jan 10 - Jan 15, 2025",
//             description: "Exploring art, museums, and coffee shops.",
//             imageUrl: "",
//             placesCount: 12,
//             daysCount: 5,
//             onTap: () {},
//           ),
//           // Example Trip 3
//           TripCard(
//             title: "Kyoto, Japan",
//             date: "Mar 01 - Mar 10, 2025",
//             description: "Cherry blossom season and temple visits.",
//             imageUrl: "",
//             placesCount: 8,
//             daysCount: 10,
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }

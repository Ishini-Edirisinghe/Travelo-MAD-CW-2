import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/trip_viewmodel.dart';
import '../widgets/trip_card.dart';
import 'trip_detail_screen.dart'; // Import the detail screen

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
          // 1. Loading State
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Empty State
          if (viewModel.trips.isEmpty) {
            return const Center(
              child: Text(
                "No trips yet. Create one!",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          // 3. List of Trips
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: viewModel.trips.length,
            itemBuilder: (context, index) {
              final trip = viewModel.trips[index];

              // Format Date: "Dec 20 - Dec 27, 2024"
              final dateRange =
                  "${DateFormat('MMM d').format(trip.startDate)} - ${DateFormat('MMM d, yyyy').format(trip.endDate)}";

              // Calculate Duration
              final days = trip.endDate.difference(trip.startDate).inDays + 1;

              // Swipe to Delete Feature
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
                  // Call delete in ViewModel
                  viewModel.deleteTrip(trip.id);

                  // Show confirmation snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${trip.title} deleted")),
                  );
                },
                child: TripCard(
                  title: trip.title,
                  date: dateRange,
                  description: trip.description,
                  imageUrl: trip.imagePath,
                  placesCount: 0, // Placeholder for now
                  daysCount: days,
                  onTap: () {
                    // Navigate to TripDetailScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TripDetailScreen(trip: trip),
                      ),
                    );
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/trip_viewmodel.dart';
import '../widgets/trip_card.dart';
import 'create_trip_screen.dart';
import 'trip_detail_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh data when this screen loads
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
          "My Trips",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove back button on tab
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF6A5AE0)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateTripScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<TripViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.trips.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: viewModel.trips.length,
            itemBuilder: (context, index) {
              final trip = viewModel.trips[index];

              // Date Formatting
              final dateRange =
                  "${DateFormat('MMM d').format(trip.startDate)} - ${DateFormat('MMM d, yyyy').format(trip.endDate)}";
              final days = trip.endDate.difference(trip.startDate).inDays + 1;

              // --- SWIPE TO DELETE WRAPPER ---
              return Dismissible(
                key: Key(trip.id), // Unique Key for Dismissible
                direction: DismissDirection.endToStart, // Swipe Right to Left
                background: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.centerRight,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, color: Colors.white, size: 30),
                      SizedBox(height: 4),
                      Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // 1. Confirm Dialog before deleting
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Delete Trip"),
                        content: const Text(
                          "Are you sure you want to delete this trip and all its memories?",
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                // 2. Action after swipe is confirmed
                onDismissed: (direction) {
                  // Call delete in ViewModel
                  viewModel.deleteTrip(trip.id);

                  // Show snackbar confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${trip.title} deleted"),
                      action: SnackBarAction(
                        label: "Undo",
                        onPressed: () {
                          // Optional: Add logic to re-add trip if needed
                          // For now, simpler to just delete
                          viewModel.addTrip(trip);
                        },
                      ),
                    ),
                  );
                },
                child: TripCard(
                  title: trip.title,
                  date: dateRange,
                  description: trip.description,
                  imageUrl: trip.imagePath,
                  placesCount: 0,
                  daysCount: days,
                  isFavorite: trip.isFavorite,
                  onFavoriteTap: () async {
                    await viewModel.toggleFavorite(trip);
                  },
                  onTap: () {
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.map_outlined, size: 40, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const Text(
            "No trips found",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateTripScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A5AE0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Create New Trip",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

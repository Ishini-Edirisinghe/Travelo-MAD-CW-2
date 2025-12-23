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
        automaticallyImplyLeading: false,
      ),
      body: Consumer<TripViewModel>(
        builder: (context, viewModel, child) {
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
                isFavorite: true,
                onFavoriteTap: () {
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
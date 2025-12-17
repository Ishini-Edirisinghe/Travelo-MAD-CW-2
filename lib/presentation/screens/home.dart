import 'package:flutter/material.dart';
import '../widgets/trip_card.dart';
// Import the new screens
import 'trips.dart';
import 'profile.dart';
// import 'create_trip_screen.dart'; // Keep this for the "New Trip" button action later

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // The 3 Main Tabs
  final List<Widget> _pages = [
    const HomeDashboardTab(), // Index 0: Home Dashboard (Defined below)
    const TripsScreen(), // Index 1: The separate Trips Screen
    const ProfileScreen(), // Index 2: The separate Profile Screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Displays the selected screen from _pages list
      body: _pages[_currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFF6A5AE0),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: "Trips",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// THE MAIN DASHBOARD TAB (Matches Home Image)
// ==========================================
class HomeDashboardTab extends StatelessWidget {
  const HomeDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER SECTION (Gradient + Stats)
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Gradient Background
              Container(
                height: 280,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6A5AE0), Color(0xFFE252CA)],
                  ),
                  // borderRadius: BorderRadius.vertical(
                  //   bottom: Radius.circular(30),
                  // ),
                ),
                child: Column(
                  children: [
                    // User Info Row
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: Color(0xFF6A5AE0),
                          ), // Placeholder
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome back,",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "Alex Johnson",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Floating Stats Box
              Positioned(
                top: 140,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      0.2,
                    ), // Glassmorphism effect
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildHeaderStat("Total Trips", "2"),
                      _buildHeaderStat("Countries", "8"),
                      _buildHeaderStat("Memories", "142"),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 60), // Space for floating box
          // 2. QUICK ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Quick Actions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Only "+ New Trip" Button as requested
                GestureDetector(
                  onTap: () {
                    // Navigate to CreateTripScreen
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTripScreen()));
                  },
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D9CDB), // Blue color from image
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2D9CDB).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 30),
                        SizedBox(height: 10),
                        Text(
                          "New Trip",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 3. MY TRIPS SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "My Trips",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // This could switch tabs to index 1 if you want
                  },
                  child: const Text(
                    "See all",
                    style: TextStyle(color: Color(0xFF6A5AE0)),
                  ),
                ),
              ],
            ),
          ),

          // 4. TRIPS LIST
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Dummy Card 1
                TripCard(
                  title: "Bali, Indonesia",
                  date: "Dec 20 - Dec 27, 2024",
                  description:
                      "A week of paradise beaches and cultural exploration.",
                  imageUrl: "",
                  placesCount: 5,
                  daysCount: 7,
                  onTap: () {},
                ),
                // Dummy Card 2
                TripCard(
                  title: "Paris, France",
                  date: "Jan 10 - Jan 15, 2025",
                  description: "Exploring art, museums, and coffee shops.",
                  imageUrl: "",
                  placesCount: 12,
                  daysCount: 5,
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper for Header Stats (White Text)
  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'data/datasources/local_datasource.dart';
import 'data/repositories/trip_repository_impl.dart';
import 'presentation/viewmodels/trip_viewmodel.dart';
// Ensure correct path

// void main() {
//   runApp(const MyApp());
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Architecture Layers
  final localDataSource = LocalDataSource();
  final tripRepository = TripRepositoryImpl(dataSource: localDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TripViewModel(repository: tripRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Diary',
      theme: ThemeData(
        useMaterial3: true,
        // This color scheme matches your purple/blue design
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A5AE0)),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelo/presentation/viewmodels/expense_viewmodel.dart'
    show ExpenseViewModel;
import 'presentation/screens/splash_screen.dart';
import 'data/datasources/local_datasource.dart';
import 'data/repositories/trip_repository_impl.dart';
import 'presentation/viewmodels/trip_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final localDataSource = LocalDataSource();
  final tripRepository = TripRepositoryImpl(localDataSource);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TripViewModel(repository: tripRepository),
        ),

        ChangeNotifierProvider(
          create: (_) => ExpenseViewModel(repository: tripRepository),
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A5AE0)),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}

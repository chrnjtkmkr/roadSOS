import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/monitoring/screens/monitoring_screen.dart';

void main() {
  // Required for plugin initialization if needed
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    // ProviderScope is required for Riverpod to work
    const ProviderScope(
      child: RoadSoSApp(),
    ),
  );
}

class RoadSoSApp extends StatelessWidget {
  const RoadSoSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'roadSoS - PRAANA',
      debugShowCheckedModeBanner: false,
      
      // Material 3 Theme Configuration
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3), // Primary Blue
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      
      // Dark Mode Support
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      
      themeMode: ThemeMode.system, // Automatically switches based on OS
      
      // Starting with the Monitoring Screen as requested
      home: const MonitoringScreen(),
    );
  }
}

/*
  Architecture Summary:
  - core: Global utilities (not yet heavily used)
  - features: Feature-based modules (Monitoring)
  - services: Hardware abstractions (SensorService)
  - models: Data structures (SensorData)
  
  State Management:
  - Riverpod is used to manage sensor streams.
  - autoDispose providers ensure that sensors are turned off 
    when the UI is not active, maximizing battery life.
*/

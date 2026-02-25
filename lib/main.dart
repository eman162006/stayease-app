import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:stayease/features/auth/login_screen.dart';
// ignore: unused_import
import 'package:stayease/features/main_navigation/main_navigation_screen.dart';
import 'package:stayease/providers/auth_provider.dart';
import 'package:stayease/providers/booking_provider.dart';
// ignore: duplicate_import

import 'providers/favorities_provider.dart';
import 'features/splash_screen.dart';
void main() {
  runApp(
   MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()..load()),
    ChangeNotifierProvider(create: (_) => FavoritesProvider()),
    ChangeNotifierProvider(create: (_) => BookingsProvider()..load()),
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
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0E7490), // teal premium
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Color(0xFF111827),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: Color(0xFF111827)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0E7490),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF0E7490),
      unselectedItemColor: Color(0xFF9CA3AF),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
    ),
  ),

 home: const SplashScreen(),
    );
  }
}


class DemoHome extends StatelessWidget {
  const DemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesProvider>();
    const propertyId = "p1";

    return Scaffold(
      appBar: AppBar(title: const Text("Provider Test")),
      body: Center(
        child: IconButton(
          iconSize: 40,
          icon: Icon(
            fav.isFavorite(propertyId) ? Icons.favorite : Icons.favorite_border,
          ),
          onPressed: () => fav.toggleFavorite(propertyId),
        ),
      ),
    );
  }
}
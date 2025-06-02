import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/time_screen.dart';
import 'screens/currency_screen.dart';
import 'screens/gold_calculator_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/lbs_tracker_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Harga Emas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFD4AF37), // Gold color
        colorScheme: ColorScheme.light(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFFB8860B),
          surface: Colors.white,
          background: Color(0xFFFFFAF0),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFD4AF37),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFD4AF37),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        scaffoldBackgroundColor: Color(0xFFFFFAF0), // Floral white
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/time': (context) => TimeScreen(),
        '/currency': (context) => CurrencyScreen(),
        '/calculator': (context) => GoldCalculatorScreen(),
        '/profile': (context) => ProfileScreen(),
        '/lbs': (context) => LBSTrackerScreen(),
      },
    );
  }
}

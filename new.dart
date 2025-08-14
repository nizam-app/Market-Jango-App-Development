// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/features/buyer/screens/cart/screen/cart_screen.dart'; // Adjust path
// ... other imports

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //Set the fit size (Find your UI design, look at the dimensions of the device screen and fill it in,unit in dp)
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      // Example design size (e.g., iPhone X) - ADJUST TO YOUR DESIGN
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Market Jango',
          theme: ThemeData( // Optional: Define a base theme
              primarySwatch: Colors.blue,
              textTheme: TextTheme(
                  bodyMedium: TextStyle(fontSize: 14.sp)) // Example default
          ),
          home: child, // child will be your home screen passed below
        );
      },
      child: const CartScreen(), // Or your initial screen like BottomNavBar
    );
  }
}
import 'package:flutter/material.dart';

class DriverHome extends StatelessWidget {
  const DriverHome({super.key});
  static final routeName ="/driverHome"; 

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Text("Driver Home"),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class DriverChat extends StatefulWidget {
  const DriverChat({super.key});
  static final routeName ="/driverChat"; 

  @override
  State<DriverChat> createState() => _DriverChatState();
}

class _DriverChatState extends State<DriverChat> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Text("Driver Chat"),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  
  static const String routeName = '/notifications_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          
          Center(
            child: Text("Categories Screen "),
          ),
        ],
      ),
    );
  }
}
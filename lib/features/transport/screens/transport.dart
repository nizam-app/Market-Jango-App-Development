import 'package:flutter/material.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});
  static const String routeName = '/transport'; 


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Text("TransportScreen"),
      ),
    );
  }
}
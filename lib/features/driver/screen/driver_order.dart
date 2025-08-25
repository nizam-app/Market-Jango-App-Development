import 'package:flutter/material.dart';

class DriverOrder extends StatefulWidget {
  const DriverOrder({super.key});
  static final routeName ="/driverOrder"; 


  @override
  State<DriverOrder> createState() => _DriverOrderState();
}

class _DriverOrderState extends State<DriverOrder> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(child: Text("Order"),),
    );
  }
}
import 'package:flutter/material.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});
  
  static const String routeName = '/chart_screen';

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Text("Chart Screen"),
      ),
    );
  }
}
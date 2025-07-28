import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});
  
  static const String routeName = '/categories_screen';

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
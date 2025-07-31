import 'package:flutter/material.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child:
      SingleChildScrollView(
        child: Column(
          children: [
            Tuppertextandbackbutton(screenName: "Filteing Name")
           
          ],
        ),
      )),
    );
  }
}

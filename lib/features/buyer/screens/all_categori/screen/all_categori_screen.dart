import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/features/buyer/widgets/custom_categories.dart';


class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const String routeName = '/categories_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                   Tuppertextandbackbutton(screenName: "All Categories"),
                    CustomCategories(categoriCount: 8,scrollableCheck: AlwaysScrollableScrollPhysics(),)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
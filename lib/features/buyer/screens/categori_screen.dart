import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                    Text("Categories Screen",style:Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 24) ,),
                    SizedBox(height: 20.h,),
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
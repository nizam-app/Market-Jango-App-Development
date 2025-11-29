import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/localization/translation_kay.dart';
import 'package:market_jango/features/buyer/screens/filter/model/all_categoris_show_model.dart';

import '../data/all_categoris_show_data.dart';

class LocationFilteringTab extends ConsumerStatefulWidget {
  const LocationFilteringTab({super.key});

  @override
  ConsumerState<LocationFilteringTab> createState() =>
      _LocationFilteringTabState();
}

class _LocationFilteringTabState extends ConsumerState<LocationFilteringTab> {
  int? _selectedCategoryId; // dropdown value = category id

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(locationCategoriesProvider);
    TextTheme theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.32),
      body: Stack(
        children: [
          Opacity(opacity: 0.4, child: Container(color: Colors.black)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: AllColor.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  SizedBox(height: 15.h),

                  /// Location
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      //"Enter your Location"
                      ref.t(TKeys.enterLocation),
                      style: theme.headlineMedium!.copyWith(fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  TextField(
                    decoration: buildInputDecoration().copyWith(
                      hintText: "Search your location",
                      prefixIcon: Icon(Icons.search_rounded, size: 27.sp),
                      fillColor: AllColor.grey100,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  /// Category dropdown
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      ref.t(TKeys.categories),
                      style: theme.headlineMedium!.copyWith(fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 5.h),

                  categoriesAsync.when(
                    loading: () => DropdownButtonFormField<int>(
                      decoration: buildInputDecoration(),
                      items: const [],
                      onChanged: null,
                      hint: Text('Loading categories...'),
                    ),
                    error: (e, _) => DropdownButtonFormField<int>(
                      decoration: buildInputDecoration(),
                      items: const [],
                      onChanged: null,
                      hint: const Text('Failed to load categories'),
                    ),
                    data: (page) {
                      final List<LocationCategoryItem> list = page.data;

                      if (list.isEmpty) {
                        return DropdownButtonFormField<int>(
                          decoration: buildInputDecoration(),
                          items: const [],
                          onChanged: null,
                          hint: const Text('No categories found'),
                        );
                      }

                      return DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: buildInputDecoration(),
                        hint: Text(
                          'Select category',
                          style: theme.headlineMedium,
                        ),
                        items: list
                            .map(
                              (c) => DropdownMenuItem<int>(
                                value: c.id,
                                child: Text(
                                  c.name,
                                  style: theme.headlineMedium,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategoryId = value);
                          // চাইলে এখান থেকে provider এও পাঠাতে পারো
                          // ref.read(selectedCategoryIdProvider.notifier).state = value;
                        },
                      );
                    },
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AllColor.dropDown,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    );
  }
}

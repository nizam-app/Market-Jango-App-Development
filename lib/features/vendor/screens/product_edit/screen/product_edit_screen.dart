import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/vendor/screens/vendor_product_add_page/widget/custom_variant_picker.dart';

import '../../../widgets/custom_back_button.dart';
import '../../vendor_home/model/vendor_product_model.dart';

class ProductEditScreen extends StatefulWidget {
  const ProductEditScreen({super.key, required this.product});

  final Product product;

  static const String routeName = '/vendor_product_edit';

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  String? selectedCategory = "Fashion / Trend Loop";
  String? selectedColor = "Blue";
  String? selectedSize = "M";

  final List<String> categories = ["Fashion / Trend Loop", "Shoes", "Jewelry"];
  final List<String> colors = ["Blue", "Red", "Green", "Black"];
  final List<String> sizes = ["S", "M", "L", "XL"];

  late TextEditingController nameController;

  late TextEditingController descriptionController;

  late TextEditingController priceController;

  final ThemeData dropTheme = ThemeData(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
  );

  @override
  void initState() {
    nameController = TextEditingController(text: widget.product.name);
    descriptionController = TextEditingController(
      text: widget.product.description,
    );
    priceController = TextEditingController(
      text: widget.product.sellPrice.toString(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 439.h,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.product.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(top: 50, left: 30, child: CustomBackButton()),
                ],
              ),
              SizedBox(height: 10.h),
              SizedBox(
                height: 80.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 76.w,
                      width: 76.w,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/imgF.png"),
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                      ),
                    );
                  },
                  separatorBuilder: (context, position) {
                    return SizedBox(width: 10.w);
                  },
                ),
              ),
              SizedBox(height: 10.h),

              /// Category Dropdown
              Theme(
                data: dropTheme,
                child: Container(
                  height: 56.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: AllColor.white,
                    // borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 14.r,
                        offset: Offset(0, 6.h),
                        color: Colors.black.withOpacity(0.06),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedCategory,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                      items: categories.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: Text(e),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() {
                          selectedCategory = v;
                        });
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              /// Product Name
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  fillColor: AllColor.white,
                  enabledBorder: OutlineInputBorder().copyWith(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.zero,
                  ),
                  focusedBorder: OutlineInputBorder().copyWith(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              /// Description
              TextFormField(
                controller: descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  fillColor: AllColor.white,
                  enabledBorder: OutlineInputBorder().copyWith(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.zero,
                  ),
                  focusedBorder: OutlineInputBorder().copyWith(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 15.h),

              /// Color & Size Dropdown
              CustomVariantPicker(),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Expanded(
              //       child: Theme(
              //         data: dropTheme,
              //         child: Container(
              //           height: 56.h,
              //           margin: EdgeInsets.only(right: 5.w),
              //           padding: EdgeInsets.symmetric(horizontal: 16.w),
              //           decoration: BoxDecoration(
              //             color: AllColor.white,
              //             // borderRadius: BorderRadius.circular(24.r),
              //             boxShadow: [
              //               BoxShadow(
              //                 blurRadius: 14.r,
              //                 offset: Offset(0, 6.h),
              //                 color: Colors.black.withOpacity(0.06),
              //               ),
              //             ],
              //           ),
              //           child: DropdownButtonHideUnderline(
              //             child: DropdownButton<String>(
              //               isExpanded: true,
              //               value: selectedColor,
              //               icon: const Icon(Icons.keyboard_arrow_down_rounded),
              //               dropdownColor: Colors.white,
              //               borderRadius: BorderRadius.circular(16.r),
              //               style: TextStyle(
              //                 fontSize: 15.sp,
              //                 color: Colors.black87,
              //               ),
              //               items: colors.map((e) {
              //                 return DropdownMenuItem(
              //                   value: e,
              //                   child: Padding(
              //                     padding: EdgeInsets.symmetric(vertical: 12.h),
              //                     child: Text(e),
              //                   ),
              //                 );
              //               }).toList(),
              //               onChanged: (v) {
              //                 setState(() {
              //                   selectedColor = v;
              //                 });
              //               },
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //     Expanded(
              //       child: Theme(
              //         data: dropTheme,
              //         child: Container(
              //           height: 56.h,
              //           margin: EdgeInsets.only(left: 5.w),
              //           padding: EdgeInsets.symmetric(horizontal: 16.w),
              //           decoration: BoxDecoration(
              //             color: AllColor.white,
              //             // borderRadius: BorderRadius.circular(24.r),
              //             boxShadow: [
              //               BoxShadow(
              //                 blurRadius: 14.r,
              //                 offset: Offset(0, 6.h),
              //                 color: Colors.black.withOpacity(0.06),
              //               ),
              //             ],
              //           ),
              //           child: DropdownButtonHideUnderline(
              //             child: DropdownButton<String>(
              //               isExpanded: true,
              //               value: selectedSize,
              //               icon: const Icon(Icons.keyboard_arrow_down_rounded),
              //               dropdownColor: Colors.white,
              //               borderRadius: BorderRadius.circular(16.r),
              //               style: TextStyle(
              //                 fontSize: 15.sp,
              //                 color: Colors.black87,
              //               ),
              //               items: sizes.map((e) {
              //                 return DropdownMenuItem(
              //                   value: e,
              //                   child: Padding(
              //                     padding: EdgeInsets.symmetric(vertical: 12.h),
              //                     child: Text(e),
              //                   ),
              //                 );
              //               }).toList(),
              //               onChanged: (v) {
              //                 setState(() {
              //                   selectedSize = v;
              //                 });
              //               },
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: 15.h),

              /// Price
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  fillColor: AllColor.white,
                  enabledBorder: OutlineInputBorder().copyWith(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.zero,
                  ),
                  focusedBorder: OutlineInputBorder().copyWith(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              /// Save Button
              ElevatedButton(
                onPressed: () {
                  // TODO: Handle save logic
                  print("Category: $selectedCategory");
                  print("Color: $selectedColor");
                  print("Size: $selectedSize");
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    AllColor.loginButtomColor,
                  ),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  fixedSize: WidgetStatePropertyAll(Size.fromWidth(80.w)),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  ),
                ),
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();

    // TODO: implement dispose
    super.dispose();
  }
}

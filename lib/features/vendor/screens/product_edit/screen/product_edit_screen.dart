import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/vendor/screens/product_edit/data/product_attribute_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/data/vendor_product_category_riverpod.dart';
import 'package:market_jango/features/vendor/screens/vendor_product_add_page/widget/custom_variant_picker.dart';

import '../../../widgets/custom_back_button.dart';
import '../../vendor_home/model/vendor_product_model.dart';
import '../model/product_attribute_response_model.dart';

class ProductEditScreen extends ConsumerStatefulWidget {
  const ProductEditScreen({super.key, required this.product});

  final Product product;

  static const String routeName = '/vendor_product_edit';

  @override
  ConsumerState<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends ConsumerState<ProductEditScreen> {
  String? _selectedCategory ;

  final ImagePicker _picker = ImagePicker();

  File? mainImage;
  List<File> extraImages = [];

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
    _selectedCategory = widget.product.categoryName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final categoryAsync = ref.watch(vendorCategoryProvider(VendorAPIController.vendor_category));
    final attributeAsync = ref.watch(productAttributesProvider);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 439.h,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:       mainImage != null
                              ? FileImage(mainImage!)
                              : NetworkImage(widget.product.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      right: 15,
                      child: GestureDetector(
                        onTap: () {
                          _askImageSource(isMain: true) ;
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
                Positioned(top: 50, left: 30, child: CustomBackButton()),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 15.h),
                  ProductImageCarousel(product: widget.product,onAddImage:() => _askImageSource(isMain: false) ,)  ,
                  SizedBox(height: 10.h),

                  /// Category Dropdown
                  categoryAsync.when(
                    data: (categories) {
                      final categoryNames = categories.map((e) => e.name).toList();
                      return Theme(
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
                              value: _selectedCategory,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                              items: categoryNames.map((e) {
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
                                  _selectedCategory = v;
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
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
                  attributeAsync.when(
                      data: (data) {

                        final sizeAttr = data.data.firstWhere(
                              (attr) => attr.name.toLowerCase() == 'size',
                          orElse: () => ProductAttribute(id: 0, name: '', vendorId: 0, attributeValues: []),
                        );


                        final colorAttr = data.data.firstWhere(
                              (attr) => attr.name.toLowerCase() == 'color',
                          orElse: () => ProductAttribute(id: 0, name: '', vendorId: 0, attributeValues: []),
                        );

                        final List<String> sizeNames = sizeAttr.attributeValues.map((v) => v.name).toList();

                        final List<String> colorNames = colorAttr.attributeValues.map((v) => v.name).toList();

                        return CustomVariantPicker(colors: colorNames,sizes: sizeNames,selectedColors:widget.product.colors,selectedSizes: widget.product.sizes,);
                      } ,loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err'))

                  ),

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
                  Align(
                    alignment: Alignment.topLeft,
                    child: ElevatedButton(
                      onPressed: () {
                    
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          AllColor.loginButtomColor,
                        ),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        fixedSize: WidgetStatePropertyAll(Size.fromWidth(90.w)),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                        ),
                      ),
                      child: Text("Save"),
                    ),
                  ),
                  SizedBox(height: 15.h,)
                  
                ],
              ),
            ),
           
          ],
        ),
      ),
    );
  }
  Future<void> pickMainImage(source) async {
    final xFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (xFile != null) {
      setState(() => mainImage = File(xFile.path));
    }
  }

  Future<void> pickExtraImage(source) async {
    final xFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (xFile != null) {
      setState(() => extraImages.add(File(xFile.path)));
    }
  }
  void _askImageSource({required bool isMain}) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  isMain
                      ? pickMainImage(ImageSource.camera)
                      : pickExtraImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  isMain
                      ? pickMainImage(ImageSource.gallery)
                      : pickExtraImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
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


class ProductImageCarousel extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddImage;
  const ProductImageCarousel({
    super.key,
    required this.product,
    this.onAddImage,
  });

  @override
  Widget build(BuildContext context) {
    final images = product.images;

    if (images.isEmpty) {
      return Container(
        height: 160.h,
        alignment: Alignment.center,
        child: const Text(
          "No images available",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 80.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemCount: images.length + 1, // ✅ +1 for add image box
        separatorBuilder: (context, _) => SizedBox(width: 15.w),
        itemBuilder: (context, index) {
          // ✅ last item will be Add Image box
          if (index == images.length) {
            return GestureDetector(
              onTap: onAddImage,
              child: Container(
                height: 76.w,
                width: 76.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6.r,
                      offset: Offset(0, 3.h),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Center(
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    color: Colors.blueAccent,
                    size: 26.sp,
                  ),
                ),
              ),
            );
          }

          // ✅ normal image box
          final imageUrl = images[index].imagePath.isNotEmpty
              ? images[index].imagePath
              : product.image;

          return Container(
            height: 76.w,
            width: 76.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6.r,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(6.w),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
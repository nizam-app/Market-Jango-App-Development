import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/global_save_botton.dart';
import 'package:market_jango/features/vendor/screens/product_edit/model/product_attribute_response_model.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/data/vendor_product_category_riverpod.dart';
import 'package:market_jango/features/vendor/screens/vendor_product_add_page/data/selecd_color_size_list.dart';
import 'package:market_jango/features/vendor/screens/vendor_product_add_page/logic/creat_product_provider.dart';

import '../../product_edit/data/product_attribute_data.dart';
import '../widget/custom_variant_picker.dart';

class ProductAddPage extends ConsumerWidget {
   ProductAddPage({super.key,});

  static final String routeName = "/productAddPage";


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attributeAsync = ref.watch(productAttributesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Column(
              children: [
                Tuppertextandbackbutton(screenName: "Profile Edite"),
                ProductBasicInfoSection(),
                SizedBox(height: 16.h),
              attributeAsync.when(
                data: (data) {
                  final colorAttr = data.data.firstWhere(
                        (attr) => attr.name.toLowerCase() == 'color',
                    orElse: () => ProductAttribute(id: 0, name: '', vendorId: 0, attributeValues: []),
                  );
                  final List<String> colorNames = colorAttr.attributeValues.map((v) => v.name ?? "").toList();

                  final sizeAttr = data.data.firstWhere(
                        (attr) => attr.name.toLowerCase() == 'size',
                    orElse: () => ProductAttribute(id: 0, name: '', vendorId: 0, attributeValues: []),
                  );
                  final List<String> sizeNames = sizeAttr.attributeValues.map((v) => v.name ?? "").toList();


                  final selectedColors = ref.watch(selectedColorsProvider);
                  final selectedSizes  = ref.watch(selectedSizesProvider);

                  return CustomVariantPicker(
                    colors: colorNames,
                    sizes: sizeNames,

                    selectedColors: selectedColors,
                    selectedSizes: selectedSizes,

                    
                    onColorsChanged: (list) {
                      ref.read(selectedColorsProvider.notifier).state = [...list];
                    },
                    onSizesChanged: (list) {
                      ref.read(selectedSizesProvider.notifier).state = [...list];  }
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),

              SizedBox(height: 16.h),
                PriceAndImagesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductBasicInfoSection extends ConsumerStatefulWidget {
  const ProductBasicInfoSection({super.key});

  @override
  ConsumerState<ProductBasicInfoSection> createState() =>
      _ProductBasicInfoSectionState();
}

class _ProductBasicInfoSectionState extends ConsumerState<ProductBasicInfoSection> {
  final _titleC = TextEditingController();
  final _descC = TextEditingController(

  );

  String? selectedCategory;

  // colors tuned to the mock
  final _lblColor = const Color(0xFF436AA0); // label text

  final _hintText = const Color(0xFF95A6C4); // (optional) hint color

  OutlineInputBorder _border() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.r),
    borderSide: BorderSide(color: AllColor.grey, width: 1.2),

  );

  @override
  Widget build(BuildContext context) {
   
    final ThemeData _dropTheme = ThemeData(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );


    final categoryAsync = ref.watch(vendorCategoryProvider(VendorAPIController.vendor_category));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Product Title', color: _lblColor),
        SizedBox(height: 6.h),
        TextFormField(
          onChanged: (value) {
            ref.read(productNameProvider.notifier).state = value;
          },
          controller: _titleC,
          style: TextStyle(fontSize: 16.sp),
          decoration: InputDecoration(
            hintText: 'Enter Product Title',
            fillColor: AllColor.white,
            enabledBorder: _border(),
            focusedBorder: _border(),
          ),
        ),

        SizedBox(height: 16.h),

        _Label('Category', color: _lblColor),
        SizedBox(height: 6.h),
        /// Category Dropdown
        categoryAsync.when(
          data: (categories) {
            final categoryNames = categories.map((e) => e.name).toList();
            if (selectedCategory == null ||
                !categoryNames.contains(selectedCategory)) {
              selectedCategory =
              categoryNames.isNotEmpty ? categoryNames.first : null;
            }
            
            return Theme(
              data: _dropTheme,
              child: Container(
                height: 56.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AllColor.white,
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(color: AllColor.grey),
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
                      if (v == null) return;
                      setState(() => selectedCategory = v);
                      final selected =
                      categories.firstWhere((e) => e.name == v);
                      ref.read(productCategoryProvider.notifier).state =
                          selected.id;
                    },
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),

        SizedBox(height: 16.h),

        _Label('Description', color: _lblColor),
        SizedBox(height: 6.h),
        TextFormField(
          onChanged: (value) {
            ref.read(productDescProvider.notifier).state = value;
          },
          controller: _descC,
          maxLines: 6,
          style: TextStyle(fontSize: 16.sp, height: 1.35),
          decoration: InputDecoration(
            hintText: 'Enter Product Description...',
            fillColor: AllColor.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
            border: _border(),
            enabledBorder: _border(),
            focusedBorder: _border(),
            hintStyle: TextStyle(color: _hintText),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

class PriceAndImagesSection extends ConsumerStatefulWidget{
  const PriceAndImagesSection({super.key,});


  @override
  ConsumerState<PriceAndImagesSection> createState() => _PriceAndImagesSectionState();
}

class _PriceAndImagesSectionState extends ConsumerState<PriceAndImagesSection> {


  @override
  Widget build(BuildContext context) {
    // Colors to mimic the screenshot
    const borderBlue = Color(0xFFBFD5F1);
    const labelBlue = Color(0xFF2B6CB0);
    final createState = ref.watch(createProductProvider);


    OutlineInputBorder _border([Color c = borderBlue]) => OutlineInputBorder(
      borderSide: BorderSide(color: c, width: 1.2),
      borderRadius: BorderRadius.circular(8.r),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prices row
          Row(
            children: [
              Expanded(
                child: _Labeled(
                  label: 'Current price',
                  labelColor: labelBlue,
                  child: TextField(
                    controller: _currentC,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      fillColor: AllColor.white,
                      hintText: 'Current Price',
                      enabledBorder: _border(),
                      focusedBorder: _border(),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: _Labeled(
                  label: 'Previous price',
                  labelColor: labelBlue,
                  child: TextField(
                    controller: _previousC,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      fillColor: AllColor.white,
                      hintText: 'Previous Price',
                      enabledBorder: _border(),
                      focusedBorder: _border(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Cover image
          _Labeled(
            label: 'Cover Image',
            labelColor: labelBlue,
            child: _UploadCard(text: 'Upload Image', onTap: _askImageSource),
          ),
          SizedBox(height: 10.h),

          // Single preview
          if (_cover != null)  _SectionTitle('Uploaded Preview', labelBlue),
          SizedBox(height: 8.h),
          if (_cover != null)    SizedBox(
            height: 64.w,
            child: Align(
              alignment: Alignment.centerLeft,
              child:  _PreviewTile(file: _cover, size: 64.w),
            ),
          ),
          SizedBox(height: 18.h),

          // Gallery images
       _Labeled(
            label: 'Gallery Images',
            labelColor: labelBlue,
            child: _UploadCard(
              text: 'Upload Multiple Images',
              onTap: _pickGallery,
            ),
          ),
          SizedBox(height: 10.h),

          if (_gallery.isNotEmpty)   _SectionTitle('Uploaded Preview', labelBlue),
          SizedBox(height: 8.h),

          // Grid of previews (show empty placeholders if none)
        Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: List.generate(_gallery.length, (i) {
              final file = i < _gallery.length ? _gallery[i] : null;
              return _PreviewTile(file: file, size: 64.w);
            }),
          ),
          SizedBox(height: 20.h),
          createState.when(
            data: (data) {
             bool loading = createState.isLoading;
             final selectedColors = ref.read(selectedColorsProvider);
             final selectedSizes = ref.read(selectedSizesProvider);
              return GlobalSaveBotton(
                bottonName:loading? "Creating": "Create a Product",
                onPressed: () {
               final   createAsync = ref.read(createProductProvider.notifier);
               final name = ref.watch(productNameProvider);
               final desc = ref.watch(productDescProvider);
               final categoryId = ref.watch(productCategoryProvider);
               createAsync.createProduct(
                   name: name,
                   description: desc,
                 regularPrice:   _currentC.text,
                 sellPrice: _previousC.text,
                   categoryId: categoryId ?? 1,
                   color: selectedColors,
                   size: selectedSizes,
                 image: File(_cover!.path),
                 files: _gallery.map((x) => File(x.path)).toList(),
               ) ;

                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }
  final _currentC = TextEditingController();
  final _previousC = TextEditingController();

  final _picker = ImagePicker();

  XFile? _cover;
  final List<XFile> _gallery = [];

  Future<void> _pickCover(source) async {
    final x = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (x != null) setState(() => _cover = x);
  }

  Future<void> _pickGallery() async {
    final xs = await _picker.pickMultiImage(imageQuality: 85);
    if (xs.isNotEmpty)
      setState(
            () => _gallery
          ..clear()
          ..addAll(xs.take(8)),
      ); // cap to 8 for neat grid
  }
  void _askImageSource() {
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

                  _pickCover(ImageSource.camera) ;

                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickCover(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({
    required this.label,
    required this.child,
    this.labelColor = const Color(0xFF2B6CB0),
  });
  final String label;
  final Widget child;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFDFE7F1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF606F85),
                ),
              ),
            ),
            Icon(
              Icons.cloud_upload_outlined,
              color: const Color(0xFF94A3B8),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.file, required this.size});
  final XFile? file;
  final double size;

  @override
  Widget build(BuildContext context) {
    final borderColor = const Color(0xFFCBD5E1);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: file == null
          ? const SizedBox.shrink()
          : Image.file(File(file!.path), fit: BoxFit.cover),
    );
  }
}

Widget _SectionTitle(String t, Color c) => Text(
  t,
  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: c),
);
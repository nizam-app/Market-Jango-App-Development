import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/global_save_botton.dart';
class ProductEditePage extends StatelessWidget {
  const ProductEditePage({super.key});
 static final String routeName = "/productEditePage" ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      SafeArea(child:
      SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.all(10.r),
          child: Column(
            children: [
              Tuppertextandbackbutton(screenName: "Profile Edite"),
              ProductBasicInfoSection()   ,
              SizedBox(height: 16.h,) ,
              VariantPicker(),
              SizedBox(height: 16.h,) ,
              PriceAndImagesSection()
            ],
          ),
        ),
      )),
    );
  }
}
class ProductBasicInfoSection extends StatefulWidget {
  const ProductBasicInfoSection({super.key});

  @override
  State<ProductBasicInfoSection> createState() => _ProductBasicInfoSectionState();
}

class _ProductBasicInfoSectionState extends State<ProductBasicInfoSection> {
  final _titleC = TextEditingController(text: 'Flowy summer dress');
  final _descC  = TextEditingController(
    text:
    "Discover a curated collection of stylish and fashionable women’s dresses designed for every mood and moment. From elegant evenings to everyday charm — dress to express.\n\nDiscover a curated collection of stylish and fashionable women’s dresses.",
  );

  final _categories = const ['Fashion', 'Electronics', 'Beauty', 'Home'];
  String _selectedCategory = 'Fashion';

  // colors tuned to the mock
  final _lblColor = const Color(0xFF436AA0);     // label text
  final _bdColor  = const Color(0xFFD2E1F6);     // border color
  final _hintText = const Color(0xFF95A6C4);     // (optional) hint color

  OutlineInputBorder _border() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.r),
    borderSide: BorderSide(color: _bdColor, width: 1.2),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Product Title', color: _lblColor),
        SizedBox(height: 6.h),
        TextFormField(
          controller: _titleC,
          style: TextStyle(fontSize: 16.sp),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            border: _border(),
            enabledBorder: _border(),
            focusedBorder: _border(),
          ),
        ),

        SizedBox(height: 16.h),

        _Label('Category', color: _lblColor),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          items: _categories
              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 16.sp))))
              .toList(),
          onChanged: (v) => setState(() => _selectedCategory = v!),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            border: _border(),
            enabledBorder: _border(),
            focusedBorder: _border(),
          ),
        ),

        SizedBox(height: 16.h),

        _Label('Description', color: _lblColor),
        SizedBox(height: 6.h),
        TextFormField(
          controller: _descC,
          maxLines: 6,
          style: TextStyle(fontSize: 16.sp, height: 1.35),
          decoration: InputDecoration(
            isDense: true,
            alignLabelWithHint: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
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


class VariantPicker extends StatefulWidget {
  const VariantPicker({
    super.key,
    this.colors = const [
      Color(0xFFE53935),
      Color(0xFF40C4FF),
      Color(0xFF76FF03),
      Color(0xFF7C4DFF),
      Color(0xFFEF9A9A),
      Color(0xFF9E9D24),
      Color(0xFF7CB342),
      Color(0xFFB0BEC5),
    ],
    this.sizes = const ['S', 'M', 'L', 'XL', 'XXL'],
    this.onColorChanged,
    this.onSizeChanged,
  });

  final List<Color> colors;
  final List<String> sizes;
  final ValueChanged<Color>? onColorChanged;
  final ValueChanged<String>? onSizeChanged;

  @override
  State<VariantPicker> createState() => _VariantPickerState();
}

class _VariantPickerState extends State<VariantPicker> {
  int _selectedColor = 0;
  String _selectedSize = 'S';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ===== Left: Color =====
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(label: 'Select Color'),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: List.generate(widget.colors.length, (i) {
                  final isSelected = i == _selectedColor;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedColor = i);
                      widget.onColorChanged?.call(widget.colors[i]);
                    },
                    child: _ColorDot(
                      color: widget.colors[i],
                      selected: isSelected,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        SizedBox(width: 14.w),

        // ===== Right: Size =====
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(label: 'Select Size'),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: widget.sizes.map((s) {
                  final selected = _selectedSize == s;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedSize = s);
                      widget.onSizeChanged?.call(s);
                    },
                    child: _SizeChip(label: s, selected: selected),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Top rounded card with chevron (visual only, like the mock)
class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14000000),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF444444),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, size: 22.sp, color: const Color(0xFF7A7A7A)),
        ],
      ),
    );
  }
}

/// Round color swatch with black ring (thicker when selected)
class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, this.selected = false});
  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: Colors.black,
          width: selected ? 4.w : 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          )
        ],
      ),
    );
  }
}

/// Light pill chip for sizes (blue-tinted like the mock)
class _SizeChip extends StatelessWidget {
  const _SizeChip({required this.label, this.selected = false});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFD9E9FF) : const Color(0xFFEFF5FD);
    final fg = selected ? const Color(0xFF2E6CE6) : const Color(0xFF7A8EAD);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
class PriceAndImagesSection extends StatefulWidget {
  const PriceAndImagesSection({super.key});

  @override
  State<PriceAndImagesSection> createState() => _PriceAndImagesSectionState();
}

class _PriceAndImagesSectionState extends State<PriceAndImagesSection> {
  final _currentC = TextEditingController(text: '\$65');
  final _previousC = TextEditingController(text: '\$100');

  final _picker = ImagePicker();

  XFile? _cover;
  final List<XFile> _gallery = [];

  Future<void> _pickCover() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) setState(() => _cover = x);
  }

  Future<void> _pickGallery() async {
    final xs = await _picker.pickMultiImage(imageQuality: 85);
    if (xs.isNotEmpty) setState(() => _gallery
      ..clear()
      ..addAll(xs.take(8))); // cap to 8 for neat grid
  }

  @override
  Widget build(BuildContext context) {
    // Colors to mimic the screenshot
    const borderBlue = Color(0xFFBFD5F1);
    const labelBlue = Color(0xFF2B6CB0);

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
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      isDense: true,
                      border: _border(),
                      enabledBorder: _border(),
                      focusedBorder: _border(labelBlue),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      isDense: true,
                      border: _border(),
                      enabledBorder: _border(),
                      focusedBorder: _border(labelBlue),
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
            child: _UploadCard(
              text: 'Upload Image',
              onTap: _pickCover,
            ),
          ),
          SizedBox(height: 10.h),

          // Single preview
          _SectionTitle('Uploaded Preview', labelBlue),
          SizedBox(height: 8.h),
          SizedBox(
            height: 64.w,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _PreviewTile(file: _cover, size: 64.w),
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

          _SectionTitle('Uploaded Preview', labelBlue),
          SizedBox(height: 8.h),

          // Grid of previews (show empty placeholders if none)
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: List.generate(4, (i) {
              final file = i < _gallery.length ? _gallery[i] : null;
              return _PreviewTile(file: file, size: 64.w);
            }),
          ),
          SizedBox(height: 20.h,)               ,
          GlobalSaveBotton(bottonName: "Update Now", onPressed: (){
            context.push("location");
          })
        ],
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child, this.labelColor = const Color(0xFF2B6CB0)});
  final String label;
  final Widget child;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: labelColor,
            )),
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
                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF606F85)),
              ),
            ),
            Icon(Icons.cloud_upload_outlined, color: const Color(0xFF94A3B8), size: 20.sp),
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
  style: TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: c,
  ),
);
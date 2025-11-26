import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/global_save_botton.dart';

import '../logic/vendor_category_add_logic.dart';

class CategoryAddPage extends StatelessWidget {
  const CategoryAddPage({super.key});
  static const routeName = "/categoryAddPage";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            children: [
              Tuppertextandbackbutton(screenName: "Category Add"),
              SizedBox(height: 16.h),
              const Expanded(child: CategoryFormSection()),
            ],
          ),
        ),
      ),
    );
  }
}

/// ======================= FORM SECTION =======================

class CategoryFormSection extends ConsumerStatefulWidget {
  const CategoryFormSection({super.key});

  @override
  ConsumerState<CategoryFormSection> createState() =>
      _CategoryFormSectionState();
}

class _CategoryFormSectionState extends ConsumerState<CategoryFormSection> {
  final _titleC = TextEditingController();
  final _descC = TextEditingController();
  final _picker = ImagePicker();

  final List<XFile> _images = [];
  bool _active = true;
  bool _isSaving = false;

  Future<void> _pickImages() async {
    final xs = await _picker.pickMultiImage(
      imageQuality: 70,       // একটু compress রাখলাম
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (xs == null || xs.isEmpty) return;

    setState(() {
      _images
        ..clear()
        ..addAll(xs);
    });
  }

  Future<void> _submit() async {
    if (_titleC.text.trim().isEmpty) {
      _showSnack('Please enter category title');
      return;
    }
    if (_descC.text.trim().isEmpty) {
      _showSnack('Please enter description');
      return;
    }
    if (_images.isEmpty) {
      _showSnack('Please select at least one image');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final created = await createCategoryApi(
        ref: ref,
        name: _titleC.text.trim(),
        description: _descC.text.trim(),
        isActive: _active,
        images: _images,
      );

      _showSnack('Category "${created.name}" created successfully');

      if (mounted) {
        Navigator.pop(context, created);
      }
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const labelBlue = Color(0xFF2B6CB0);
    const borderBlue = Color(0xFFBFD5F1);

    OutlineInputBorder _border([Color c = borderBlue]) => OutlineInputBorder(
      borderSide: BorderSide(color: c, width: 1.2),
      borderRadius: BorderRadius.circular(8.r),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Title
          const _Label('Category Title', labelBlue),
          SizedBox(height: 6.h),
          TextField(
            controller: _titleC,
            decoration: InputDecoration(
              hintText: 'Enter your title here',
              isDense: true,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              border: _border(),
              enabledBorder: _border(),
              focusedBorder: _border(labelBlue),
            ),
          ),
          SizedBox(height: 14.h),

          // Description
          const _Label('Category Description', labelBlue),
          SizedBox(height: 6.h),
          TextField(
            controller: _descC,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Enter your description here',
              alignLabelWithHint: true,
              contentPadding: EdgeInsets.all(12.w),
              border: _border(),
              enabledBorder: _border(),
              focusedBorder: _border(labelBlue),
            ),
          ),
          SizedBox(height: 14.h),

          // Upload
          const _Label('Upload Category Images', labelBlue),
          SizedBox(height: 6.h),
          InkWell(
            onTap: _pickImages,
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
                      _images.isEmpty
                          ? 'Upload Images'
                          : '${_images.length} image(s) selected',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF606F85),
                      ),
                      overflow: TextOverflow.ellipsis,
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
          ),
          SizedBox(height: 12.h),

          // Preview grid
          if (_images.isNotEmpty) ...[
            const _Label('Uploaded Preview', labelBlue),
            SizedBox(height: 8.h),
            SizedBox(
              height: 70.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) {
                  final img = _images[i];
                  return Stack(
                    children: [
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6.r),
                          border:
                          Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.file(
                          File(img.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: -6,
                        top: -6,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            setState(() => _images.removeAt(i));
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          SizedBox(height: 18.h),

          // Status row
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     const _Label('Status', Colors.black87),
          //     Row(
          //       children: [
          //         Text(
          //           'Active',
          //           style: TextStyle(
          //             fontSize: 14.sp,
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //         SizedBox(width: 8.w),
          //         Switch(
          //           value: _active,
          //           activeColor: Colors.white,
          //           activeTrackColor: const Color(0xFFF59E0B),
          //           inactiveThumbColor: Colors.white,
          //           inactiveTrackColor: const Color(0xFFCBD5E1),
          //           onChanged: (v) => setState(() => _active = v),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
          // SizedBox(height: 20.h),

          GlobalSaveBotton(
            bottonName: _isSaving ? "Saving..." : "Save Category",
            onPressed: _isSaving ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, this.color, {super.key});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
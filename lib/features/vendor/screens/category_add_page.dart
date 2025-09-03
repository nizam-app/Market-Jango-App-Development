import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/global_save_botton.dart';
class CategoryAddPage extends StatelessWidget {
  const CategoryAddPage({super.key});
  static final routeName = "/categoryAddPage" ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child:
      Padding(
        padding:  EdgeInsets.all(20.r),
        child: Column(
          children: [
            Tuppertextandbackbutton(screenName: "Category Add"),
            CategoryFormSection()
          ],
        ),
      )),
    );
  }
}

class CategoryFormSection extends StatefulWidget {
  const CategoryFormSection({super.key});

  @override
  State<CategoryFormSection> createState() => _CategoryFormSectionState();
}

class _CategoryFormSectionState extends State<CategoryFormSection> {
  final _titleC = TextEditingController();
  final _descC  = TextEditingController();
  final _picker = ImagePicker();

  XFile? _image;
  bool _active = true;

  Future<void> _pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) setState(() => _image = x);
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
          _Label('Category Title', labelBlue),
          SizedBox(height: 6.h),
          TextField(
            controller: _titleC,
            decoration: InputDecoration(
              hintText: 'Enter your title here',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              border: _border(),
              enabledBorder: _border(),
              focusedBorder: _border(labelBlue),
            ),
          ),
          SizedBox(height: 14.h),

          // Description
          _Label('Category Description', labelBlue),
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
          _Label('Upload Category Image', labelBlue),
          SizedBox(height: 6.h),
          InkWell(
            onTap: _pickImage,
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
                    child: Text('Upload Image',
                      style: TextStyle(fontSize: 13.sp, color: const Color(0xFF606F85)),
                    ),
                  ),
                  Icon(Icons.cloud_upload_outlined, color: const Color(0xFF94A3B8), size: 20.sp),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Preview
          _Label('Uploaded Preview', labelBlue),
          SizedBox(height: 8.h),
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            clipBehavior: Clip.antiAlias,
            child: _image == null
                ? const SizedBox.shrink()
                : Image.file(File(_image!.path), fit: BoxFit.cover),
          ),
          SizedBox(height: 18.h),

          // Status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Label('Status', Colors.black87),
              Row(
                children: [
                  Text('Active', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(width: 8.w),
                  Switch(
                    value: _active,
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xFFF59E0B), // orange
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFCBD5E1),
                    onChanged: (v) => setState(() => _active = v),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h,) ,
          GlobalSaveBotton(bottonName: "Save Category", onPressed: (){})
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
    return Text(text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ));
  }
}
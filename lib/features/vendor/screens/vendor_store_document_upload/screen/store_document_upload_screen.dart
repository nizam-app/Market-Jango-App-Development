import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart'
    as vendor;

class StoreDocumentUploadScreen extends ConsumerStatefulWidget {
  const StoreDocumentUploadScreen({super.key});

  static const String routeName = '/store_document_upload';

  @override
  ConsumerState<StoreDocumentUploadScreen> createState() =>
      _StoreDocumentUploadScreenState();
}

class _StoreDocumentUploadScreenState
    extends ConsumerState<StoreDocumentUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedImages = await _picker.pickMultiImage(
        imageQuality: 85,
      );

      if (pickedImages.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedImages);
        });
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: "Error",
          message: "Failed to pick images: ${e.toString()}",
          type: CustomSnackType.error,
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        setState(() {
          _selectedImages.add(pickedImage);
        });
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: "Error",
          message: "Failed to capture image: ${e.toString()}",
          type: CustomSnackType.error,
        );
      }
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery (Multiple)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitDocuments() {
    if (_selectedImages.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: "Error",
        message: "Please select at least one document image",
        type: CustomSnackType.error,
      );
      return;
    }

    // TODO: Implement your upload logic here
    // Convert XFile to File if needed: File(_selectedImages[index].path)
    
    GlobalSnackbar.show(
      context,
      title: "Success",
      message: "${_selectedImages.length} document(s) ready to upload",
      type: CustomSnackType.success,
    );

    // Navigate back or to next screen
    // context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30.h),
                const vendor.CustomBackButton(),
                SizedBox(height: 20.h),
                Center(
                  child: Text(
                    "Upload Your Documents",
                    style: textTheme.titleLarge,
                  ),
                ),
                SizedBox(height: 10.h),
                Center(
                  child: Text(
                    "Select multiple images for your store documents",
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 40.h),

                // Upload Button
                InkWell(
                  onTap: _showImageSourceOptions,
                  child: Container(
                    width: double.infinity,
                    height: 60.h,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AllColor.textBorderColor,
                        width: 0.5.sp,
                      ),
                      borderRadius: BorderRadius.circular(30.r),
                      color: AllColor.orange50,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload_file,
                          color: AllColor.textHintColor,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          _selectedImages.isEmpty
                              ? 'Select Multiple Images'
                              : 'Add More Images',
                          style: textTheme.bodyMedium!.copyWith(
                            color: AllColor.textHintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Selected Images Count
                if (_selectedImages.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Text(
                      "${_selectedImages.length} image(s) selected",
                      style: textTheme.bodyMedium!.copyWith(
                        color: AllColor.green500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                SizedBox(height: 20.h),

                // Images Grid
                if (_selectedImages.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 1,
                    ),
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.file(
                              File(_selectedImages[index].path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 4.h,
                            right: 4.w,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: EdgeInsets.all(4.sp),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                if (_selectedImages.isEmpty)
                  Container(
                    width: double.infinity,
                    height: 200.h,
                    decoration: BoxDecoration(
                      color: AllColor.grey100,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AllColor.textBorderColor,
                        width: 0.5.sp,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 64.sp,
                          color: AllColor.grey500,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "No images selected",
                          style: textTheme.bodyMedium!.copyWith(
                            color: AllColor.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 50.h),

                // Submit Button
                CustomAuthButton(
                  buttonText: "Upload Documents",
                  onTap: _submitDocuments,
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
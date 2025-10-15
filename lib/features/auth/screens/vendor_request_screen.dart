import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/api_control/auth_api.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/phone_number.dart';

import '../logic/register_vendor_request_riverpod.dart';

class VendorRequestScreen extends ConsumerStatefulWidget {
  const VendorRequestScreen({super.key});

  static final String routeName = '/vendor_request';

  @override
  ConsumerState<VendorRequestScreen> createState() =>
      _VendorRequestScreenState();
}

class _VendorRequestScreenState extends ConsumerState<VendorRequestScreen> {
  Country? _selectedCountry;
  String? _selectedBusinessType;
  final _businessNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  List<File> _pickedFiles = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'doc', 'docx'],
    );
    if (result != null) {
      setState(() {
        _pickedFiles = result.paths.map((e) => File(e!)).toList();
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedCountry == null ||
        _businessNameCtrl.text.isEmpty ||
        _selectedBusinessType == null ||
        _addressCtrl.text.isEmpty ||
        _pickedFiles.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: "Error",
        message: "All fields are required including documents",
        type: CustomSnackType.error,
      );
      return;
    }

    final notifier = ref.read(vendorRegisterProvider.notifier);
    await notifier.registerVendor(
      url: AuthAPIController.registerVendorRequestStore,
      // 🔁 replace with your endpoint
      country: _selectedCountry!.name,
      businessName: _businessNameCtrl.text.trim(),
      businessType: _selectedBusinessType!,
      address: _addressCtrl.text.trim(),
      files: _pickedFiles,
    );

    final state = ref.read(vendorRegisterProvider);
    state.when(
      data: (vendor) {
        if (vendor != null) {
          GlobalSnackbar.show(
            context,
            title: "Success",
            message: "Vendor registered successfully!",
            type: CustomSnackType.success,
          );
          context.push(PhoneNumberScreen.routeName);
        }
      },
      error: (e, _) => GlobalSnackbar.show(
        context,
        title: "Error",
        message: e.toString(),
        type: CustomSnackType.error,
      ),
      loading: () {},
    );
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (country) => setState(() => _selectedCountry = country),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(vendorRegisterProvider).isLoading;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                const CustomBackButton(),
                SizedBox(height: 20.h),
                Center(
                  child: Text("Create Store", style: textTheme.titleLarge),
                ),
                SizedBox(height: 10.h),
                Center(
                  child: Text(
                    "Get started with your access in a few steps",
                    style: textTheme.bodySmall,
                  ),
                ),

                SizedBox(height: 40.h),

                // ---- Country Picker ----
                GestureDetector(
                  onTap: _showCountryPicker,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: AllColor.orange50,
                      border: Border.all(color: AllColor.outerAlinment),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedCountry?.name ?? 'Choose Your Country',
                          style: textTheme.bodyMedium,
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                // ---- Business Name ----
                TextFormField(
                  controller: _businessNameCtrl,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Enter your Business Name',
                  ),
                ),

                SizedBox(height: 30.h),

                // ---- Business Type ----
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF8E7),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AllColor.outerAlinment),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("Choose Your Business Type"),
                      value: _selectedBusinessType,
                      icon: const Icon(Icons.arrow_drop_down),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      items:
                          const [
                            'E-commerce',
                            'Electronics',
                            'Fashion & Clothing',
                            'Beauty & Cosmetics',
                            'Plumbers',
                            'Electricians',
                            'Painters',
                          ].map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedBusinessType = value),
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                // ---- Address ----
                TextFormField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Enter your full address',
                  ),
                ),

                SizedBox(height: 28.h),

                // ---- File Upload ----
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Upload your documents",
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                InkWell(
                  onTap: _pickFiles,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AllColor.outerAlinment),
                      borderRadius: BorderRadius.circular(25.r),
                      color: AllColor.orange50,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _pickedFiles.isEmpty
                              ? 'Upload Multiple Files'
                              : '${_pickedFiles.length} file(s) selected',
                          style: textTheme.bodyMedium,
                        ),
                        const Icon(Icons.upload_file),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 62.h),

                CustomAuthButton(
                  buttonText: loading ? "Submitting..." : "Next",
                  onTap: loading ? () {} : _submit,
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

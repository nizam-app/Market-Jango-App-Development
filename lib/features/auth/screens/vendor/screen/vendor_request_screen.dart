import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:market_jango/core/constants/api_control/auth_api.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/screen/google_map/data/location_store.dart';
import 'package:market_jango/core/screen/google_map/screen/google_map.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/global_locaiton_button.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/phone_number_screen.dart';

import '../../../data/vendor_business_type_data.dart';
import '../../../logic/register_vendor_request_riverpod.dart';

class VendorRequestScreen extends ConsumerWidget {
  const VendorRequestScreen({super.key});

  static const String routeName = '/vendor_request';

  Future<void> _pickFiles(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'doc', 'docx'],
    );

    if (result != null) {
      ref.read(pickedFilesProvider.notifier).state = result.paths
          .map((e) => File(e!))
          .toList();
    }
  }

  void _showCountryPicker(BuildContext context, WidgetRef ref) {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (country) {
        ref.read(selectedCountryProvider.notifier).state = country;
      },
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final country = ref.read(selectedCountryProvider);
    final businessName = ref.read(businessNameProvider);
    final businessType = ref.read(selectedBusinessTypeProvider);
    final address = ref.read(addressProvider);
    final files = ref.read(pickedFilesProvider);
    final latitude = ref.read(selectedLatitudeProvider);
    final longitude = ref.read(selectedLongitudeProvider);

    if (country == null ||
        businessName.isEmpty ||
        businessType == null ||
        address.isEmpty ||
        files.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: "Error",
        message: "All fields are required including documents",
        type: CustomSnackType.error,
      );
      return;
    }

    ref.read(vendorLoadingProvider.notifier).state = true;

    final notifier = ref.read(vendorRegisterProvider.notifier);
    await notifier.registerVendor(
      url: AuthAPIController.registerVendorRequestStore,
      country: country.name,
      businessName: businessName,
      businessType: businessType,
      address: address,
      files: files,
      latitude: latitude, // Pass latitude
      longitude: longitude, // Pass longitude
    );

    ref.read(vendorLoadingProvider.notifier).state = false;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final country = ref.watch(selectedCountryProvider);
    final businessName = ref.watch(businessNameProvider);
    final address = ref.watch(addressProvider);
    final files = ref.watch(pickedFilesProvider);
    final loading = ref.watch(vendorLoadingProvider);

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
                Text(
                  "Get started with your access in a few steps",
                  style: textTheme.bodySmall,
                ),
                SizedBox(height: 40.h),

                // Country Picker
                GestureDetector(
                  onTap: () => _showCountryPicker(context, ref),
                  child: Container(
                    height: 60.h,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: AllColor.orange50,
                      border: Border.all(
                        color: AllColor.textBorderColor,
                        width: 0.5.sp,
                      ),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          country?.name ?? 'Choose Your Country',
                          style: textTheme.bodyMedium,
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 28.h),

                // Business Name
                TextFormField(
                  initialValue: businessName,
                  onChanged: (v) =>
                      ref.read(businessNameProvider.notifier).state = v,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Enter your Business Name',
                  ),
                ),
                SizedBox(height: 30.h),

                // Business Type
                const BusinessTypeDropdown(),
                SizedBox(height: 28.h),

                // Address
                TextFormField(
                  initialValue: address,
                  onChanged: (v) =>
                      ref.read(addressProvider.notifier).state = v,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Enter your full address',
                  ),
                ),

                SizedBox(height: 28.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Text(
                        "Store Location",
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    LocationButton(
                      onTap: () async {
                        final result = await context.push<LatLng>(
                          GoogleMapScreen.routeName,
                        );

                        if (result != null) {
                          print(
                            "LOCATION RECEIVED → ${result.latitude}, ${result.longitude}",
                          );

                          // Store latitude and longitude in providers
                          ref.read(selectedLatitudeProvider.notifier).state =
                              result.latitude;
                          ref.read(selectedLongitudeProvider.notifier).state =
                              result.longitude;

                          // Optional: Show success message
                          GlobalSnackbar.show(
                            context,
                            title: "Success",
                            message: "Location selected successfully!",
                            type: CustomSnackType.success,
                          );
                        }
                      },
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final lat = ref.watch(selectedLatitudeProvider);
                        final lng = ref.watch(selectedLongitudeProvider);

                        if (lat != null && lng != null) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h, left: 15.w),
                            child: Text(
                              "Selected: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}",
                              style: textTheme.bodySmall!.copyWith(
                                color: Colors.green,
                              ),
                            ),
                          );
                        }
                        return SizedBox();
                      },
                    ),

                    // File Upload
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
                      onTap: () => _pickFiles(context, ref),
                      child: Container(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              files.isEmpty
                                  ? 'Upload Multiple Files'
                                  : '${files.length} file(s) selected',
                              style: textTheme.bodyMedium!.copyWith(
                                color: AllColor.textHintColor,
                              ),
                            ),
                            const Icon(Icons.upload_file),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 50.h),

                    // Submit Button
                    CustomAuthButton(
                      buttonText: loading ? "Submitting..." : "Next",
                      onTap: loading ? () {} : () => _submit(context, ref),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final selectedCountryProvider = StateProvider<Country?>((ref) => null);

// Business Type
final selectedBusinessTypeProvider = StateProvider<String?>((ref) => null);

// Business Name
final businessNameProvider = StateProvider<String>((ref) => "");

// Address
final addressProvider = StateProvider<String>((ref) => "");

// Files
final pickedFilesProvider = StateProvider<List<File>>((ref) => []);

// Loading State
final vendorLoadingProvider = StateProvider<bool>((ref) => false);

class BusinessTypeDropdown extends ConsumerWidget {
  const BusinessTypeDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessTypesAsync = ref.watch(businessTypesProvider);
    final selectedType = ref.watch(selectedBusinessTypeProvider);

    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AllColor.orange50,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: AllColor.textBorderColor, width: 0.5.sp),
      ),
      child: businessTypesAsync.when(
        data: (types) => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text(
              "Choose Your Business Type",
              style: TextStyle(color: AllColor.textHintColor, fontSize: 14.sp),
            ),
            value: selectedType,
            icon: Icon(Icons.arrow_drop_down, size: 24.sp),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            items: types.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AllColor.textHintColor,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              ref.read(selectedBusinessTypeProvider.notifier).state = value;
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            const Center(child: Text("Data is not available")),
      ),
    );
  }
}

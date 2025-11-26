import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/screen/google_map/data/location_store.dart';
import 'package:market_jango/core/screen/google_map/screen/google_map.dart';
import 'package:market_jango/core/screen/profile_screen/data/profile_data.dart';
import 'package:market_jango/core/screen/profile_screen/logic/user_data_update_riverpod.dart';
import 'package:market_jango/core/screen/profile_screen/model/profile_model.dart';
import 'package:market_jango/core/theme/text_theme.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/global_locaiton_button.dart';
import 'package:market_jango/core/widget/global_save_botton.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';

class BuyerProfileEditScreen extends ConsumerStatefulWidget {
  const BuyerProfileEditScreen({super.key, required this.user});
  static const routeName = "/buyerProfileEditScreen";

  final UserModel user;

  @override
  ConsumerState<BuyerProfileEditScreen> createState() =>
      _BuyerProfileEditScreenState();
}

class _BuyerProfileEditScreenState
    extends ConsumerState<BuyerProfileEditScreen> {
  // ---------- common ----------
  late TextEditingController nameC;
  late TextEditingController emailC;
  late TextEditingController phoneC;

  // ---------- buyer ----------
  late TextEditingController ageC;
  late TextEditingController aboutC;
  late TextEditingController shipLocationC; // text field "Ship Location"

  // ---------- vendor / transport ----------
  // late TextEditingController languageC; // vendor
  late TextEditingController countryC; // vendor
  late TextEditingController addressC; // vendor + transport
  late TextEditingController businessNameC; // vendor
  // late TextEditingController businessTypeC; // vendor

  // Local backup state
  double? _backupLat;
  double? _backupLng;
  String? _selectedGender;
  File? _mainImage;
  final ImagePicker _picker = ImagePicker();

  // --- user type helpers (API থেকে আসা user_type ধরে নাও) ---
  bool get isBuyer => widget.user.userType?.toLowerCase() == 'buyer';
  bool get isVendor => widget.user.userType?.toLowerCase() == 'vendor';
  bool get isTransport => widget.user.userType?.toLowerCase() == 'transport';

  @override
  void initState() {
    super.initState();

    // --------- common ----------
    nameC = TextEditingController(text: widget.user.name ?? '');
    emailC = TextEditingController(text: widget.user.email ?? '');
    phoneC = TextEditingController(text: widget.user.phone ?? '');

    // --------- buyer ----------
    ageC = TextEditingController(text: widget.user.buyer?.age ?? '');
    aboutC = TextEditingController(text: widget.user.buyer?.description ?? '');
    shipLocationC = TextEditingController(
      text: widget.user.buyer?.shipLocation ?? '',
    );

    _selectedGender = widget.user.buyer?.gender;

    // --------- vendor / transport ----------
    // এখানে safe ভাবে empty রাখছি – চাইলে পরে model থেকে value বসাতে পারো
    // languageC = TextEditingController(text: widget.user.language ?? '');
    countryC = TextEditingController(text: widget.user.vendor?.country ?? '');
    addressC = TextEditingController(text: widget.user.vendor?.address ?? '');
    businessNameC = TextEditingController(
      text: widget.user.vendor?.businessName ?? '',
    );
    // businessTypeC = TextEditingController(
    //   text: widget.user.vendor?.businessType ?? '',
    // );

    _initializeLocationData();
  }

  void _initializeLocationData() {
    // প্রথমে TempStorage check করুন
    if (TempLocationStorage.hasLocation) {
      _backupLat = TempLocationStorage.latitude;
      _backupLng = TempLocationStorage.longitude;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedLatitudeProvider.notifier).state = _backupLat;
        ref.read(selectedLongitudeProvider.notifier).state = _backupLng;
      });
    }
    // তারপর existing buyer location (যদি থাকে) ব্যবহার করুন
    else if (widget.user.buyer?.latitude != null &&
        widget.user.buyer?.longitude != null) {
      _backupLat = double.tryParse(widget.user.buyer?.latitude ?? '');
      _backupLng = double.tryParse(widget.user.buyer?.longitude ?? '');

      if (_backupLat == null || _backupLng == null) return;

      TempLocationStorage.setLocation(_backupLat!, _backupLng!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedLatitudeProvider.notifier).state = _backupLat;
        ref.read(selectedLongitudeProvider.notifier).state = _backupLng;
      });
    }
  }

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    phoneC.dispose();

    ageC.dispose();
    aboutC.dispose();
    shipLocationC.dispose();

    // languageC.dispose();
    countryC.dispose();
    addressC.dispose();
    businessNameC.dispose();
    // businessTypeC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updateUserLoading = ref.watch(updateUserProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Tuppertextandbackbutton(screenName: "My Profile"),
                SizedBox(height: 16.h),
                buildStackProfileImage(widget.user.image),
                SizedBox(height: 16.h),

                // ------------ Common fields ------------
                CustomTextFormField(label: "Your Name", controller: nameC),
                SizedBox(height: 12.h),
                CustomTextFormField(label: "Email", controller: emailC),
                SizedBox(height: 12.h),
                CustomTextFormField(label: "Phone", controller: phoneC),

                // ------------ Buyer only fields ------------
                if (isBuyer) ...[
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Gender",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: InputDecoration(
                                fillColor: const Color(0xffE6F0F8),
                                hintText: "Select Gender",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: const BorderSide(
                                    color: Color(0xff0168B8),
                                    width: 0.2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: const BorderSide(
                                    color: Color(0xff0168B8),
                                    width: 0.2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: const BorderSide(
                                    color: Color(0xff0168B8),
                                    width: 0.2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                              items: <String>['Male', 'Female']
                                  .map(
                                    (value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender = newValue;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: CustomTextFormField(
                          label: "Age",
                          controller: ageC,
                          hintText: "Enter Age",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  CustomTextFormField(
                    label: "About",
                    controller: aboutC,
                    maxLines: 3,
                  ),
                  SizedBox(height: 12.h),
                  CustomTextFormField(
                    label: "Ship Location",
                    controller: shipLocationC,
                    hintText: "Enter Location",
                  ),
                ],

                // ------------ Vendor only fields ------------
                if (isVendor) ...[
                  // SizedBox(height: 12.h),
                  // CustomTextFormField(
                  //   label: "Language",
                  //   controller: languageC,
                  //   hintText: "Enter Language",
                  // ),
                  SizedBox(height: 12.h),
                  CustomTextFormField(
                    label: "Country",
                    controller: countryC,
                    hintText: "Enter Country",
                  ),
                  SizedBox(height: 12.h),
                  CustomTextFormField(
                    label: "Address",
                    controller: addressC,
                    hintText: "Enter Address",
                  ),
                  SizedBox(height: 12.h),
                  CustomTextFormField(
                    label: "Business Name",
                    controller: businessNameC,
                    hintText: "Enter Business Name",
                  ),
                  SizedBox(height: 12.h),
                  // CustomTextFormField(
                  //   label: "Business Type",
                  //   controller: businessTypeC,
                  //   hintText: "Enter Business Type",
                  // ),
                ],

                // ------------ Transport only fields ------------
                if (isTransport) ...[
                  SizedBox(height: 12.h),
                  CustomTextFormField(
                    label: "Address",
                    controller: addressC,
                    hintText: "Enter Address",
                  ),
                ],

                SizedBox(height: 28.h),

                // ------------ Location button (all user type) ------------
                LocationButton(
                  onTap: () async {
                    final currentLat =
                        ref.read(selectedLatitudeProvider) ?? _backupLat;
                    final currentLng =
                        ref.read(selectedLongitudeProvider) ?? _backupLng;

                    LatLng? initialLocation;
                    if (currentLat != null && currentLng != null) {
                      initialLocation = LatLng(currentLat, currentLng);
                    }

                    final result = await context.push<LatLng>(
                      GoogleMapScreen.routeName,
                      extra: initialLocation,
                    );

                    if (result != null) {
                      ref.read(selectedLatitudeProvider.notifier).state =
                          result.latitude;
                      ref.read(selectedLongitudeProvider.notifier).state =
                          result.longitude;
                      TempLocationStorage.setLocation(
                        result.latitude,
                        result.longitude,
                      );
                      setState(() {
                        _backupLat = result.latitude;
                        _backupLng = result.longitude;
                      });

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
                    final providerLat = ref.watch(selectedLatitudeProvider);
                    final providerLng = ref.watch(selectedLongitudeProvider);

                    final lat =
                        providerLat ??
                        TempLocationStorage.latitude ??
                        _backupLat;
                    final lng =
                        providerLng ??
                        TempLocationStorage.longitude ??
                        _backupLng;

                    if (lat != null && lng != null) {
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h, left: 15.w),
                        child: Text(
                          "Selected: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}",
                          style:
                              textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                              ) ??
                              TextStyle(fontSize: 12.sp, color: Colors.green),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),

                SizedBox(height: 30.h),

                GlobalSaveBotton(
                  bottonName: updateUserLoading ? "Saving..." : "Save Changes",
                  onPressed: () async {
                    if (updateUserLoading) return;

                    final providerLat = ref.read(selectedLatitudeProvider);
                    final providerLng = ref.read(selectedLongitudeProvider);
                    final lat =
                        providerLat ??
                        TempLocationStorage.latitude ??
                        _backupLat;
                    final lng =
                        providerLng ??
                        TempLocationStorage.longitude ??
                        _backupLng;

                    final notifier = ref.read(updateUserProvider.notifier);
                    bool ok = false;

                    if (isBuyer) {
                      ok = await notifier.updateUser(
                        userType: 'buyer',
                        name: nameC.text.trim(),
                        gender: _selectedGender,
                        age: ageC.text.trim(),
                        description: aboutC.text.trim(),
                        country: _extractCountry(shipLocationC.text),
                        shipLocation: shipLocationC.text.trim(),
                        shipCity: _extractCity(shipLocationC.text),
                        latitude: lat,
                        longitude: lng,
                        image: _mainImage,
                      );
                    } else if (isVendor) {
                      ok = await notifier.updateUser(
                        userType: 'vendor',
                        name: nameC.text.trim(),
                        // language: languageC.text.trim(),
                        country: countryC.text.trim(),
                        address: addressC.text.trim(),
                        businessName: businessNameC.text.trim(),
                        // businessType: businessTypeC.text.trim(),
                        latitude: lat,
                        longitude: lng,
                        image: _mainImage,
                      );
                    } else if (isTransport) {
                      ok = await notifier.updateUser(
                        userType: 'transport',
                        name: nameC.text.trim(),
                        address: addressC.text.trim(),
                        latitude: lat,
                        longitude: lng,
                        image: _mainImage,
                      );
                    }

                    if (!context.mounted) return;

                    if (ok) {
                      context.pop();
                      GlobalSnackbar.show(
                        context,
                        title: "Success",
                        message: "Profile updated successfully",
                      );
                      ref.invalidate(userProvider);
                    } else {
                      final errMsg = ref
                          .read(updateUserProvider)
                          .maybeWhen(
                            error: (e, __) => e.toString(),
                            orElse: () => 'Update failed',
                          );
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(errMsg)));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods
  String _extractCountry(String location) {
    if (location.isEmpty) return '';
    final parts = location.split(' ');
    return parts.isNotEmpty ? parts.last : '';
  }

  String _extractCity(String location) {
    if (location.isEmpty) return '';
    final parts = location.split(' ');
    return parts.isNotEmpty ? parts.first : '';
  }

  Stack buildStackProfileImage(String? image) {
    return Stack(
      children: [
        CircleAvatar(radius: 30.r, backgroundImage: _getProfileImage(image)),
        Positioned(
          bottom: 0.h,
          right: 0.w,
          child: InkWell(
            onTap: _askImageSource,
            child: CircleAvatar(
              radius: 12.r,
              backgroundColor: AllColor.white,
              child: Padding(
                padding: EdgeInsets.all(5.r),
                child: Icon(
                  Icons.camera_alt,
                  color: AllColor.black,
                  size: 15.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider _getProfileImage(String? image) {
    if (_mainImage != null) {
      return FileImage(_mainImage!);
    } else if (image != null && image.isNotEmpty) {
      return NetworkImage(image);
    } else {
      return const AssetImage('assets/images/default_avatar.png');
    }
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
                  pickMainImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  pickMainImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickMainImage(ImageSource source) async {
    final xFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (xFile != null) {
      setState(() => _mainImage = File(xFile.path));
    }
  }
}

// ---------- Reusable text field ----------
class CustomTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final int? maxLines;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            fillColor: const Color(0xffE6F0F8),
            hintText: hintText ?? label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(
                color: Color(0xff0168B8),
                width: 0.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(
                color: Color(0xff0168B8),
                width: 0.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(
                color: Color(0xff0168B8),
                width: 0.2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }
}

// lib/core/screen/google_map/data/temp_storage.dart
class TempLocationStorage {
  static double? _latitude;
  static double? _longitude;

  static double? get latitude => _latitude;
  static double? get longitude => _longitude;

  static void setLocation(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
  }

  static void clear() {
    _latitude = null;
    _longitude = null;
  }

  static bool get hasLocation => _latitude != null && _longitude != null;
}

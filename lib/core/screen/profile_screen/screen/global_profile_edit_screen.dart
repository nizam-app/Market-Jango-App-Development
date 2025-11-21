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
  static final routeName = "/buyerProfileEditScreen";
  final UserModel user;

  @override
  ConsumerState<BuyerProfileEditScreen> createState() =>
      _BuyerProfileEditScreenState();
}

class _BuyerProfileEditScreenState
    extends ConsumerState<BuyerProfileEditScreen> {
  late TextEditingController nameC;
  late TextEditingController emailC;
  late TextEditingController phoneC;
  late TextEditingController ageC;
  late TextEditingController aboutC;
  late TextEditingController locationC;

  // Local backup state
  double? _backupLat;
  double? _backupLng;
  String? _selectedGender;
  File? _mainImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Initialize controllers with user data
    nameC = TextEditingController(text: widget.user.name ?? '');
    emailC = TextEditingController(text: widget.user.email ?? '');
    phoneC = TextEditingController(text: widget.user.phone ?? '');
    ageC = TextEditingController(text: widget.user.buyer?.age ?? '');
    aboutC = TextEditingController(text: widget.user.buyer?.description ?? '');
    locationC = TextEditingController(
      text: widget.user.buyer?.shipLocation ?? '',
    );

    // Set default value for gender dropdown
    _selectedGender = widget.user.buyer?.gender;

    // Initialize location data
    _initializeLocationData();
  }

  void _initializeLocationData() {
    // প্রথমে TempStorage check করুন
    if (TempLocationStorage.hasLocation) {
      _backupLat = TempLocationStorage.latitude;
      _backupLng = TempLocationStorage.longitude;

      // Provider এও save করুন
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedLatitudeProvider.notifier).state = _backupLat;
        ref.read(selectedLongitudeProvider.notifier).state = _backupLng;
      });
    }
    // তারপর existing user data check করুন
    else if (widget.user.buyer?.latitude != null &&
        widget.user.buyer?.longitude != null) {
      // Safely parse String? to double? to prevent type errors.
      _backupLat = double.tryParse(widget.user.buyer?.latitude ?? '');
      _backupLng = double.tryParse(widget.user.buyer?.longitude ?? '');

      // Only proceed if parsing was successful
      if (_backupLat == null || _backupLng == null) return;

      // TempStorage ও Provider এ save করুন
      TempLocationStorage.setLocation(_backupLat!, _backupLng!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedLatitudeProvider.notifier).state = _backupLat;
        ref.read(selectedLongitudeProvider.notifier).state = _backupLng;
      });
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    nameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    ageC.dispose();
    aboutC.dispose();
    locationC.dispose();
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
              children: [
                const Tuppertextandbackbutton(screenName: "My Profile"),
                buildStackProfileImage(widget.user.image),
                CustomTextFormField(label: "Your Name", controller: nameC),
                SizedBox(height: 12.h),
                CustomTextFormField(label: "Email", controller: emailC),
                SizedBox(height: 12.h),
                CustomTextFormField(label: "Phone", controller: phoneC),

                SizedBox(height: 12.h),
                // ---- Gender & Age Row ----
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
                              fillColor: Color(0xffE6F0F8),
                              hintText: "Select Gender",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: Color(0xff0168B8),
                                  width: 0.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: Color(0xff0168B8),
                                  width: 0.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
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
                                .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                })
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
                  controller: locationC,
                  hintText: "Enter Location",
                ),

                SizedBox(height: 28.h),
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
                    );

                    if (result != null) {
                      print(
                        "LOCATION RECEIVED → ${result.latitude}, ${result.longitude}",
                      );

                      // তিন জায়গায় save করুন
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

                // Updated Consumer with multiple fallbacks
                Consumer(
                  builder: (context, ref, child) {
                    final providerLat = ref.watch(selectedLatitudeProvider);
                    final providerLng = ref.watch(selectedLongitudeProvider);

                    // Priority: Provider -> TempStorage -> Local Backup -> User Data
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
                    return SizedBox();
                  },
                ),

                SizedBox(height: 30.h),
                GlobalSaveBotton(
                  bottonName: updateUserLoading ? "Saving..." : "Save Changes",
                  onPressed: () async {
                    if (updateUserLoading) return;

                    // Final location data নিন multiple sources থেকে
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

                    final ok = await ref
                        .read(updateUserProvider.notifier)
                        .updateUser(
                          name: nameC.text.trim(),
                          gender: _selectedGender,
                          age: ageC.text.trim(),
                          description: aboutC.text.trim(),
                          country: _extractCountry(locationC.text),
                          ship_location: locationC.text.trim(),
                          latitude: lat,
                          longitude: lng,
                          shipCity: _extractCity(locationC.text),
                          image: _mainImage,
                        );

                    if (!context.mounted) return;

                    if (ok) {
                      // Success হলে TempStorage clear করুন (optional)
                      // TempLocationStorage.clear();
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
            onTap: () {
              _askImageSource();
            },
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
      return AssetImage('assets/images/default_avatar.png') as ImageProvider;
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

// CustomTextFormField widget (যদি আলাদা না থাকে)
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
            fillColor: Color(0xffE6F0F8),
            hintText: hintText ?? label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Color(0xff0168B8), width: 0.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Color(0xff0168B8), width: 0.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Color(0xff0168B8), width: 0.2),
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

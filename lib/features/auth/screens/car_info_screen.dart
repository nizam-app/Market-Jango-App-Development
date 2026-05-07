import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/api_control/auth_api.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/phone_number_screen.dart';
import '../data/route_data.dart';
import '../logic/register_car_info_riverpod.dart';


class CarInfoScreen extends ConsumerStatefulWidget {
  const CarInfoScreen({super.key});
  static const String routeName = '/car_info';

  @override
  ConsumerState<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends ConsumerState<CarInfoScreen> {
  final _carNameCtrl = TextEditingController();
  final _carModelCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String? _selectedRouteId;
  String? _selectedTransportType;
  List<File> _pickedFiles = [];
  bool _acceptedTerms = false;
  late final TapGestureRecognizer _termsTapRecognizer;

  static const List<String> _transportTypes = [
    'motorcycle',
    'car',
    'air',
    'water',
  ];

  String _labelForTransportType(String type) {
    if (type.isEmpty) return type;
    return '${type[0].toUpperCase()}${type.substring(1)}';
  }

  @override
  void initState() {
    super.initState();
    _termsTapRecognizer = TapGestureRecognizer()..onTap = _showTermsDialog;
  }

  @override
  void dispose() {
    _termsTapRecognizer.dispose();
    _carNameCtrl.dispose();
    _carModelCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _showTermsDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terms and Conditions'),
        content: SingleChildScrollView(
          child: Text(
            'By registering as a driver on Market Jango, you agree that:\n\n'
            '• The vehicle and license information you provide is accurate and up to date.\n'
            '• You will comply with applicable traffic laws and safety requirements.\n'
            '• Uploaded documents (e.g. driving license) may be verified by the platform.\n'
            '• You are responsible for the service you provide to passengers and for any pricing '
            'you list, in line with platform rules.\n'
            '• The platform may update these terms; continued use after changes constitutes acceptance.\n\n'
            'For full legal terms, refer to any official policy documents published by Market Jango.',
            style: TextStyle(fontSize: 14.sp, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _pickedFiles = result.paths
            .where((e) => e != null && File(e).existsSync())
            .map((e) => File(e!))
            .toList();
      });
    }
  }

  Future<void> _submit() async {
    if (_carNameCtrl.text.isEmpty ||
        _carModelCtrl.text.isEmpty ||
        _locationCtrl.text.isEmpty ||
        _priceCtrl.text.isEmpty ||
        _selectedTransportType == null ||
        _selectedRouteId == null ||
        _pickedFiles.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: "Error",
        message: "Please fill all fields and upload your documents",
        type: CustomSnackType.error,
      );
      return;
    }

    if (!_acceptedTerms) {
      GlobalSnackbar.show(
        context,
        title: "Error",
        message: "Please accept the Terms and Conditions to continue",
        type: CustomSnackType.error,
      );
      return;
    }

    final notifier = ref.read(driverRegisterProvider.notifier);
    await notifier.registerDriver(
      url: AuthAPIController.registerDriverCarInfo,
      carName: _carNameCtrl.text.trim(),
      carModel: _carModelCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      price: _priceCtrl.text.trim(),
      transportType: _selectedTransportType!,
      routeId: _selectedRouteId!,
      files: _pickedFiles,
    );

    await Future.delayed(const Duration(milliseconds: 100));
    final result = ref.read(driverRegisterProvider);

    if (result is AsyncData && result.value != null) {
      GlobalSnackbar.show(
        context,
        title: "Success",
        message: "Driver registered successfully!",
        type: CustomSnackType.success,
      );
      if (context.mounted) {
        context.push(PhoneNumberScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(driverRegisterProvider);
    final routeAsync = ref.watch(routeListProvider);
    final loading = asyncState.isLoading;
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
                Center(child: Text("Car Information", style: textTheme.titleLarge)),
                SizedBox(height: 20.h),
                Center(
                  child: Text("Get started with your access in just a few steps",
                      style: textTheme.bodySmall),
                ),
                SizedBox(height: 40.h),

                /// Transport type dropdown (shown first)
                Container(
                  height: 60.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF8E7),
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(
                        color: AllColor.textBorderColor, width: 0.5.sp),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("Choose Transport Type"),
                      value: _selectedTransportType,
                      icon: const Icon(Icons.arrow_drop_down),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(30.r),
                      items: _transportTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            _labelForTransportType(type),
                            style: const TextStyle(color: Colors.black87),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTransportType = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 28.h),

                TextFormField(
                  controller: _carNameCtrl,
                  decoration: const InputDecoration(hintText: 'Enter your Car Brand Name'),
                ),
                SizedBox(height: 30.h),

                TextFormField(
                  controller: _carModelCtrl,
                  decoration: const InputDecoration(hintText: 'Enter your brand model'),
                ),
                SizedBox(height: 30.h),

                TextFormField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(hintText: 'Enter your Location'),
                ),
                SizedBox(height: 30.h),

                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Enter your Price'),
                ),
                SizedBox(height: 28.h),

                /// Route dropdown
                routeAsync.when(
                  data: (routes) {
                    return Container(
                      height: 60.h,
                      padding: EdgeInsets.symmetric(horizontal: 16.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF8E7),
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(
                            color: AllColor.textBorderColor, width: 0.5.sp),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          hint: const Text("Enter your driving route"),
                          value: _selectedRouteId == null
                              ? null
                              : int.tryParse(_selectedRouteId!),
                          icon: const Icon(Icons.arrow_drop_down),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                          items: routes.map((route) {
                            return DropdownMenuItem<int>(
                              value: route.id,
                              child: Text(route.name,
                                  style: const TextStyle(color: Colors.black87)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRouteId = value?.toString();
                            });
                          },
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: Text('Loading...')),
                  error: (e, _) => Text("Failed to load routes: $e"),
                ),

                SizedBox(height: 28.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Upload your driving license & other documents",
                      style: TextStyle(fontSize: 14.sp, color: AllColor.black),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                InkWell(
                  onTap: _pickFiles,
                  child: Container(
                    height: 60.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AllColor.textBorderColor, width: 0.5.sp),
                      borderRadius: BorderRadius.circular(30.r),
                      color: AllColor.orange50,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _pickedFiles.isEmpty
                              ? 'Upload Multiple Files'
                              : '${_pickedFiles.length} file(s) selected',
                          style: TextStyle(
                            color: AllColor.textHintColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Icon(Icons.upload_file),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: Checkbox(
                          value: _acceptedTerms,
                          onChanged: (v) =>
                              setState(() => _acceptedTerms = v ?? false),
                          activeColor: AllColor.loginButtomColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AllColor.black.withValues(alpha: 0.65),
                                height: 1.35,
                              ),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: TextStyle(
                                    color: AllColor.loginButtomColor,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: _termsTapRecognizer,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),
                CustomAuthButton(
                  buttonText: loading ? "Submitting..." : "Confirm",
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

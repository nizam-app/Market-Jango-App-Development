import 'dart:io';
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
  String? _selectedRoute;
  List<File> _pickedFiles = [];

  final List<String> drivingRoutes = ['1', '2', '3', '4'];

  @override
  void dispose() {
    _carNameCtrl.dispose();
    _carModelCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // 📂 File picker
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _pickedFiles = result.paths
            .where((e) => e != null && File(e!).existsSync()) // ✅ only valid
            .map((e) => File(e!))
            .toList();
      });
    }}

  // 🚀 Submit function
  Future<void> _submit() async {
    if (_carNameCtrl.text.isEmpty ||
        _carModelCtrl.text.isEmpty ||
        _locationCtrl.text.isEmpty ||
        _priceCtrl.text.isEmpty ||
        _selectedRoute == null ||
        _pickedFiles.isEmpty) {
      GlobalSnackbar.show(context,
          title: "Error",
          message: "Please fill all fields and upload your documents",
          type: CustomSnackType.error);
      return;
    }

    final notifier = ref.read(driverRegisterProvider.notifier);
    await notifier.registerDriver(
      url: AuthAPIController.registerDriverCarInfo,
      carName: _carNameCtrl.text.trim(),
      carModel: _carModelCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      price: _priceCtrl.text.trim(),
      routeId: _selectedRoute!,
      files: _pickedFiles,
    );

    // ✅ এখন listen করবো, কিন্তু একবারই
    ref.listenManual(driverRegisterProvider, (previous, next) {
      next.whenOrNull(
        data: (res) {
          if (res != null && res.status == "success") {
            GlobalSnackbar.show(
              context,
              title: "Success",
              message: "Driver registered successfully!",
              type: CustomSnackType.success,
            );
            context.push(PhoneNumberScreen.routeName);
          }
        },
        error: (e, _) {
          GlobalSnackbar.show(
            context,
            title: "Error",
            message: e.toString(),
            type: CustomSnackType.error,
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(driverRegisterProvider);
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
                    child: Text(
                        "Get started with your access in just a few steps",
                        style: textTheme.bodySmall)),
                SizedBox(height: 40.h),

                // Car name
                TextFormField(
                  controller: _carNameCtrl,
                  decoration: const InputDecoration(
                      hintText: 'Enter your Car Brand Name'),
                ),
                SizedBox(height: 30.h),

                // Car model
                TextFormField(
                  controller: _carModelCtrl,
                  decoration:
                  const InputDecoration(hintText: 'Enter your brand model'),
                ),
                SizedBox(height: 30.h),

                // Location
                TextFormField(
                  controller: _locationCtrl,
                  decoration:
                  const InputDecoration(hintText: 'Enter your Location'),
                ),
                SizedBox(height: 30.h),

                // Price
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                  const InputDecoration(hintText: 'Enter your Price'),
                ),
                SizedBox(height: 28.h),

                // Route dropdown
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
                      hint: const Text("Enter your driving route"),
                      value: _selectedRoute,
                      icon: const Icon(Icons.arrow_drop_down),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      items: drivingRoutes.map((route) {
                        return DropdownMenuItem<String>(
                          value: route,
                          child: Text(route,
                              style: const TextStyle(color: Colors.black87)),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() {
                        _selectedRoute = value;
                      }),
                    ),
                  ),
                ),
                SizedBox(height: 28.h),

                // File upload
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Upload your driving license & other documents",
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                InkWell(
                  onTap: _pickFiles,
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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

                SizedBox(height: 40.h),
                CustomAuthButton(
                  buttonText: loading ? "Submitting..." : "Confirm",
                  onTap: loading ? (){} : _submit,
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

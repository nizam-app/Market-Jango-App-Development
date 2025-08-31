
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/phone_number.dart';

class VendorRequestScreen extends StatelessWidget {
  const VendorRequestScreen({super.key});
  static final String routeName = '/vendor_request';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                CustomBackButton(),
                VendorRequestText(),

                ChooseBusinessType(),
                NextBotton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VendorRequestText extends StatefulWidget {
  const VendorRequestText({super.key});

  @override
  State<VendorRequestText> createState() => _VendorRequestTextState();
}

class _VendorRequestTextState extends State<VendorRequestText> {
  Country? _selectedCountry;

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true, // Optional. Shows +880 etc. Remove if not needed.
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Center(child: Text("Create Store", style: textTheme.titleLarge)),
        SizedBox(height: 20.h),
        Center(
          child: Text(
            "Get started with your access in just a few steps",
            style: textTheme.bodySmall,
          ),
        ),
        SizedBox(height: 41.h),

        // Country Picker UI
        GestureDetector(
          onTap: _showCountryPicker,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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

        TextFormField(
          decoration: InputDecoration(hintText: 'Enter your Business Name'),
        ),
        SizedBox(height: 30.h),
      ],
    );
  }
}

class ChooseBusinessType extends StatefulWidget {
  const ChooseBusinessType({super.key});

  @override
  State<ChooseBusinessType> createState() => _ChooseBusinessType();
}

class _ChooseBusinessType extends State<ChooseBusinessType> {
  String? selectedUserType;

  final List<String> businessTypes = [ 'Buyer', 'Transport', 'Vendor', 'Driver'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              value: selectedUserType,
              icon: const Icon(Icons.arrow_drop_down),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(30),
              selectedItemBuilder: (context) {
                return businessTypes.map((type) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      type,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList();
              },
              items: businessTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Container(
                    width: double.infinity,
                    color: selectedUserType == type
                        ? Colors.orange
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: selectedUserType == type
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedUserType = value;
                });
              },
            ),
          ),
        ),

        SizedBox(height: 28.h),

        TextFormField(
          decoration: InputDecoration(hintText: 'Enter your full address'),
        ),
        SizedBox(height: 28.h),
        Text("Upload your documents", style: textTheme.bodyMedium),
        SizedBox(height: 12.h),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Upload Multiple Images ',
            suffixIcon: Icon(Icons.upload_file),
          ),
        ),
      ],
    );
  }
}

class NextBotton extends StatelessWidget {
  const NextBotton({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 62.h),
        CustomAuthButton(
          buttonText: "Next",
          onTap: () => nextButonDone(context),
        ),
      ],
    );
  }

  void nextButonDone(BuildContext context) {
    goToPhoneNumberScreen(context);
  }

  void goToPhoneNumberScreen(BuildContext context) {
    context.push(PhoneNumberScreen.routeName);
  }
}
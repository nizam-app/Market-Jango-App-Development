import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/name_screen.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});
  static const String routeName = '/userScreen';

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
                UserText(),
               
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class UserText extends StatefulWidget {
  const UserText({super.key});

  @override
  State<UserText> createState() => _UserTextState();
}

class _UserTextState extends State<UserText> {
  String? selectedUserType;

  final List<String> userTypes = ['Buyer', 'Transport', 'Vendor', 'Driver'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(child: Text("User Type Selection", style: textTheme.titleLarge)),
        const SizedBox(height: 24),

        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF8E7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text("Choose one"),
              value: selectedUserType,
              icon: const Icon(Icons.arrow_drop_down),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              selectedItemBuilder: (context) {
                return userTypes.map((type) {
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
              items: userTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: selectedUserType == type
                        ? Colors.orange
                        : Colors.transparent,
                    // padding:  EdgeInsets.symmetric(vertical: ),
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

        const SizedBox(height: 24),
        NextButton(role: selectedUserType?? "Buyer"), // <-- এখানে value পাঠাচ্ছি
      ],
    );
  }
}

class NextButton extends StatelessWidget {
  const NextButton({super.key, required this.role});
  final String role;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 460.h),
        CustomAuthButton(
          buttonText: "Next",
          onTap: () => nextButonDone(context,role),
        ),
      ],
    );
  }



  void nextButonDone(BuildContext context,String role) {
    context.pushNamed(NameScreen.routeName,
      pathParameters: {"role": role});
  }
}
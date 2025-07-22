import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/phone_number.dart';
   
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
            child: Column(children: [UserText(), NextBotton()]),
          ),
        ),
      ),
    );
  }
}

class UserText extends StatefulWidget {
  UserText({super.key});

  @override
  State<UserText> createState() => _UserTextState();
}

class _UserTextState extends State<UserText> {
  String? selectedUserType;

  final Map<String, List<String>> userTypes = {
    'Vendor': ['Buyer', 'Transporter'],
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30.h),
        IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        SizedBox(height: 20.h),
        Center(child: Text("User Type Selection", style: textTheme.titleLarge)),
        SizedBox(height: 24.h),
        TextFormField(
          keyboardType: TextInputType.name,
          controller: TextEditingController(text: selectedUserType ?? ""),
          decoration: InputDecoration(
            hintText: "Choose one",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
          onTap: () async {
  final String? result = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text("Select User Type"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: userTypes.entries.expand((entry) {
              return [
                // Show the main category (Vendor)
                Container(
                  color: Colors.orange.shade200,
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Show the subtypes (Buyer, Transporter)
                ...entry.value.map(
                  (subType) => ListTile(
                    title: Text(subType),
                    onTap: () {
                      Navigator.pop(context, subType);
                    },
                  ),
                ),
              ];
            }).toList(),
          ),
        ),
      );
    },
  );

  if (result != null) {
    setState(() {
      selectedUserType = result;
    });
  }
},

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
        SizedBox(height: 465.h),
        CustomAuthButton(
          buttonText: "Next",
          onTap: () => nextButonDone(context),
        ),
      ],
    );
  }

  void nextButonDone(BuildContext context) {
    goToPhoneNumber(context);
  }

  void goToPhoneNumber(BuildContext context) {
    context.push(PhoneNumberScreen.routeName);
  }
}

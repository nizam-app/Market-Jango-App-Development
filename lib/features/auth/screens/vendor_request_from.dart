import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/Congratulation.dart';

class VendorRequestFrom extends StatelessWidget {
  const VendorRequestFrom({super.key});
  static final String routeName ='/vendorRequstFrom'; 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(children: [
              VendorRequestText(), 
              VendorBusinessText(),
              NextBotton(), 



              
            ]),
          ),
        ),
      ),
    );
  }

}




class VendorBusinessText extends StatefulWidget {
 const VendorBusinessText({super.key});

  @override
  State<VendorBusinessText> createState() => _VendorBusinessTextState();
}

class _VendorBusinessTextState extends State<VendorBusinessText> {
  String? selectedUserType;

  final Map<String, List<String>> userTypes = {
    'Individual Seller ': ['Small Business', 'Company'],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30.h),
        TextFormField(
          keyboardType: TextInputType.name,
          controller: TextEditingController(text: selectedUserType ?? ""),
          decoration: InputDecoration(
            hintText: "Your Business Type",
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
        title: const Text("Your Business Type"),
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



class VendorRequestText extends StatelessWidget {
  const VendorRequestText({super.key});

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
          icon: const Icon(Icons.arrow_back_ios),
        ),
        SizedBox(height: 20.h),
        Center(child: Text("Request an account", style: textTheme.titleLarge)),
        SizedBox(height: 20.h),
        Center(
          child: Text(
            "Get started with your access in just a few steps",
            style: textTheme.bodySmall,
          ),
        ),
        SizedBox(height: 56.h),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Enter your business name',
          ),
          obscureText: true,
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
        SizedBox(height: 222.h),
        CustomAuthButton(
          buttonText: "Submit",
          onTap: () => nextButonDone(context),
        ),
      ],
    );
  }

  void nextButonDone(BuildContext context) {
    goToCongratulationScreen(context);
  }

  void goToCongratulationScreen(BuildContext context) {
    context.push(CongratulationScreen.routeName);
  }
}

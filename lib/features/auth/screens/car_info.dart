import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/email_screen.dart';

class CarInfoScreen extends StatelessWidget {
  const CarInfoScreen({super.key});
    static final String routeName = '/car_info'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(children: [
              SizedBox(height: 30.h,),
              CustomBackButton(), 
              CarInfoText(), 
              CarInfoDriverRoute(),
              NextBotton(),  

                
            ] 
          ),
        ),
      ),
    )
    );
  }
}


class CarInfoText extends StatelessWidget {
  const CarInfoText({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Center(child: Text("Car Information", style: textTheme.titleLarge)),
        SizedBox(height: 20.h),
        Center(
          child: Text(
            "Get started with your access in just a few steps",
            style: textTheme.bodySmall,
          ),
        ),
        SizedBox(height: 40.h),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Enter your Car Brand Name',
           
          ),
       
        ),
        SizedBox(height: 30.h,),
        TextFormField(
          decoration: InputDecoration(
              hintText: 'Enter your brand model ',
           
          ),
         
        ),
        
        SizedBox(height: 30.h,),
        TextFormField(
          decoration: InputDecoration(
              hintText: 'Enter your Location ',
           
          ),
          
        ),
      ],
    );
  }
}
  
  
class CarInfoDriverRoute extends StatefulWidget {
  const CarInfoDriverRoute({super.key});

  @override
  State<CarInfoDriverRoute> createState() => _CarInfoDriverRoute();
}

class _CarInfoDriverRoute extends State<CarInfoDriverRoute> {
  String? selectedUserType;

  final List<String> driginRoute = ['Rampura', 'Jomuna', 'Airport', 'Uttora'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         SizedBox(height: 28.h),
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
              value: selectedUserType,
              icon: const Icon(Icons.arrow_drop_down),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(30),
              selectedItemBuilder: (context) {
                return driginRoute.map((type) {
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
              items: driginRoute.map((type) {
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
        Text("Upload your driging license & other documents", style: textTheme.bodyMedium),
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
        SizedBox(height: 40.h),
        CustomAuthButton(
          buttonText: "Confrim",
          onTap: () => nextButonDone(context),
        ),
      ],
    );
  }

  void nextButonDone(BuildContext context) {
    goToEmailScreen(context);
  }

  void goToEmailScreen(BuildContext context) {
    context.push(EmailScreen.routeName);
  }
}
 
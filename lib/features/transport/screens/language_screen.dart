import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  static const String routeName = "/language";

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLang = "English";

  final List<String> languages = [
    "English",
    "Français",
    "Русский",
    "Tiếng Việt",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             SizedBox(height: 20.h,), 
            CustomBackButton(), 
            SizedBox(height: 10.h,), 

            Text("Settings",
            style: TextStyle(fontSize: 18.sp, color: Colors.black)),
            /// Language Title
            Text("Language",
                style: TextStyle(
                    fontSize: 14.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 16.h),

            /// Language Options
            ...languages.map((lang) {
              final bool isSelected = selectedLang == lang;
              return GestureDetector(
                onTap: () {
                  setState(() => selectedLang = lang);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.orange.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: isSelected
                            ? Colors.orange.shade100
                            : Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(lang,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black)),
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected ? Colors.blue : Colors.grey,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

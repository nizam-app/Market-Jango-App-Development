import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/screen/global_language/data/language_data.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalLanguageScreen extends ConsumerStatefulWidget {
  const GlobalLanguageScreen({super.key});
  static const String routeName = "/language";

  @override
  ConsumerState<GlobalLanguageScreen> createState() =>
      _GlobalLanguageScreenState();
}

class _GlobalLanguageScreenState extends ConsumerState<GlobalLanguageScreen> {
  String? selectedLang;

  Future<void> _saveLanguage() async {
    if (selectedLang == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', selectedLang!);
    if (mounted) Navigator.pop(context); // অথবা কোনো স্ন্যাকবার দেখাতে পারেন
  }

  @override
  Widget build(BuildContext context) {
    final asyncLangs = ref.watch(languagesProvider);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            const CustomBackButton(),
            SizedBox(height: 10.h),

            Text(
              "Settings",
              style: TextStyle(fontSize: 18.sp, color: Colors.black),
            ),
            SizedBox(height: 6.h),
            Text(
              "Language",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16.h),

            Expanded(
              child: asyncLangs.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (languages) {
                  if (languages.isEmpty) {
                    return const Center(child: Text('No languages found'));
                  }
                  selectedLang ??= languages.contains('English')
                      ? 'English'
                      : languages.first;

                  return ListView.separated(
                    itemCount: languages.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, i) {
                      final lang = languages[i];
                      final isSelected = selectedLang == lang;

                      return GestureDetector(
                        onTap: () => setState(() => selectedLang = lang),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.orange.shade50
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.orange.shade100
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
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
                    },
                  );
                },
              ),
            ),

            SizedBox(height: 12.h),
            CustomAuthButton(onTap: _saveLanguage, buttonText: 'Save'),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}

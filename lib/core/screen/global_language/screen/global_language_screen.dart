import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/screen/global_language/data/language_data.dart';
import 'package:market_jango/core/screen/global_language/data/language_update.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalLanguageScreen extends ConsumerStatefulWidget {
  const GlobalLanguageScreen({super.key});
  static const String routeName = "/language";

  @override
  ConsumerState<GlobalLanguageScreen> createState() =>
      _GlobalLanguageScreenState();
}

/// label <-> code map
const Map<String, String> _labelToCode = {
  'English': 'en',
  'Français': 'fr',
  'Русский': 'ru',
  'Tiếng Việt': 'vi',
};

const Map<String, String> _codeToLabel = {
  'en': 'English',
  'fr': 'Français',
  'ru': 'Русский',
  'vi': 'Tiếng Việt',
};

class _GlobalLanguageScreenState extends ConsumerState<GlobalLanguageScreen> {
  String? selectedLang; // label: English / Français ...

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_language'); // code or label

    if (saved == null) return;

    // jodi code save thake (en/fr/ru/vi)
    String? label = _codeToLabel[saved];

    // na hole dhore nibo label save chhilo
    label ??= _labelToCode.keys.contains(saved) ? saved : null;

    if (label == null) return;
    if (!mounted) return;

    setState(() => selectedLang = label);
  }

  Future<void> _saveLanguage() async {
    if (selectedLang == null) return;

    final code = _labelToCode[selectedLang] ?? 'en';
    final notifier = ref.read(languageUpdateProvider.notifier);

    try {
      await notifier.updateLanguage(code);

      final prefs = await SharedPreferences.getInstance();
      // eke bare code save korbo, future e easy
      await prefs.setString('app_language', code);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Language changed to $selectedLang')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncLangs = ref.watch(globallanguagesProvider);
    final updateState = ref.watch(languageUpdateProvider);
    final isSaving = updateState.isLoading;

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

                  // jodi kono saved value na thake, first ke default dhorbo
                  selectedLang ??= languages.first;

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
            CustomAuthButton(
              onTap: isSaving
                  ? () {}
                  : () {
                      _saveLanguage();
                    },
              buttonText: isSaving ? 'Saving...' : 'Save',
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}

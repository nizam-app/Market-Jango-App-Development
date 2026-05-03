import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/screen/global_language/data/language_data.dart';
import 'package:market_jango/core/screen/global_language/data/language_update.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/localization/translation_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalLanguageScreen extends ConsumerStatefulWidget {
  const GlobalLanguageScreen({super.key});
  static const String routeName = "/language";

  @override
  ConsumerState<GlobalLanguageScreen> createState() =>
      _GlobalLanguageScreenState();
}

/// Display label (as returned by `/api/language`) -> ISO-style code for `user/update`.
const Map<String, String> _labelToCode = {
  'English': 'en',
  'Français': 'fr',
  'Русский': 'ru',
  'Tiếng Việt': 'vi',
  'Kiswahili': 'sw',
  'Swahili': 'sw',
  'العربية': 'ar',
  'Arabic': 'ar',
};

/// Default label shown when restoring from saved code (must match an entry in API list if possible).
const Map<String, String> _codeToLabel = {
  'en': 'English',
  'fr': 'Français',
  'ru': 'Русский',
  'vi': 'Tiếng Việt',
  'sw': 'Kiswahili',
  'ar': 'العربية',
};

String? _labelMatchingSavedCode(String savedCode, List<String> available) {
  final preferred = _codeToLabel[savedCode];
  if (preferred != null && available.contains(preferred)) return preferred;
  for (final lang in available) {
    if ((_labelToCode[lang] ?? '') == savedCode) return lang;
  }
  return null;
}

String _codeForLabel(String label) {
  final t = label.trim();
  return _labelToCode[t] ?? 'en';
}

class _GlobalLanguageScreenState extends ConsumerState<GlobalLanguageScreen> {
  String? selectedLang; // label: English / Français ...
  String? _savedLanguageCode;
  bool _hasLoadedSavedLanguage = false;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLanguageCode();
  }

  Future<void> _loadSavedLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_language'); // code or label

    if (mounted) {
      setState(() {
        _savedLanguageCode = saved;
        _hasLoadedSavedLanguage = true;
      });
    }
  }

  void _initializeSelectedLanguage(List<String> availableLanguages) {
    if (_hasInitialized || selectedLang != null) return; // Already initialized

    String? initialLang;

    if (_savedLanguageCode != null) {
      final saved = _savedLanguageCode!.trim();
      String? label = _labelMatchingSavedCode(saved, availableLanguages);
      label ??= _labelToCode.containsKey(saved) && availableLanguages.contains(saved)
          ? saved
          : null;

      if (label != null) initialLang = label;
    }

    // If no valid saved language, use first available
    initialLang ??= availableLanguages.first;

    if (mounted) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => selectedLang = initialLang);
        }
      });
    }
  }

  Future<void> _saveLanguage() async {
    if (selectedLang == null) return;

    final code = _codeForLabel(selectedLang!);
    final notifier = ref.read(languageUpdateProvider.notifier);

    try {
      await notifier.updateLanguage(code);

      final prefs = await SharedPreferences.getInstance();
      // eke bare code save korbo, future e easy
      await prefs.setString('app_language', code);

      // Invalidate and refresh translations provider to load new language immediately
      ref.invalidate(appTranslationsProvider);
      await ref.read(appTranslationsProvider.notifier).refresh();

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
              //"Settings"
              ref.t(BKeys.settings),
              style: TextStyle(fontSize: 18.sp, color: Colors.black),
            ),
            SizedBox(height: 6.h),
            Text(
              //"Language"
              ref.t(BKeys.language),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16.h),

            Expanded(
              child: asyncLangs.when(
                loading: () => const Center(child: Text('Loading...')),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (languages) {
                  if (languages.isEmpty) {
                    return const Center(child: Text('No languages found'));
                  }

                  // Initialize selected language once when languages are available
                  if (_hasLoadedSavedLanguage) {
                    _initializeSelectedLanguage(languages);
                  }

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

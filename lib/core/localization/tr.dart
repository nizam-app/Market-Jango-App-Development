import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/core/localization/translation_providers.dart';

extension RefTranslationsX on WidgetRef {
  String t(String key, {String? fallback}) {
    // watch করলে translations load/refresh হলে widget auto rebuild হবে
    final async = watch(appTranslationsProvider);
    return async.maybeWhen(
      data: (tr) => tr.get(key, fallback: fallback),
      orElse: () => fallback ?? key,
    );
  }
}

class AppTranslations {
  final Map<String, String> _values;

  AppTranslations(this._values);

  factory AppTranslations.fromJson(Map<String, dynamic> json) {
    final map = <String, String>{};
    json.forEach((key, value) {
      map[key] = value?.toString() ?? '';
    });
    return AppTranslations(map);
  }

  /// মূল getter – খুঁজে না পেলে fallback দেয়
  String get(String key, {String? fallback}) {
    final v = _values[key];
    if (v == null || v.isEmpty) return fallback ?? key;
    return v;
  }

  /// optional: [] অপারেটর
  String operator [](String key) => get(key);
}

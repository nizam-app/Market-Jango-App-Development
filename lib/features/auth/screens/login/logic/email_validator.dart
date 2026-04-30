final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
bool isValidEmail(String s) => _emailRegex.hasMatch(s.trim());

String? emailValidator(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return 'Enter email';
  if (!isValidEmail(s)) return 'Enter a valid email';
  return null;
}

/// True if input looks like an email address (contain @).
bool looksLikeEmailInput(String s) => s.trim().contains('@');

/// Phone: accepts local/international format; validates by digit count (10–15).
bool _isValidLoginPhoneDigits(String raw) {
  final digitsOnly = raw.replaceAll(RegExp(r'\D'), '');
  return digitsOnly.length >= 10 && digitsOnly.length <= 15;
}

/// Login field: accepts **either** email or phone (email optional — phone-focused ok).
/// Used where hint is "Email or Phone number".
String? loginEmailOrPhoneValidator(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return 'Enter email or phone number';

  if (looksLikeEmailInput(s)) {
    if (!isValidEmail(s)) return 'Enter a valid email';
    return null;
  }

  if (!_isValidLoginPhoneDigits(s)) {
    return 'Enter a valid phone number';
  }

  return null;
}

/// Normalizes identifier before POST: trim; strip spaces/brackets/dashes from phones.
/// Emails unchanged except trim.
String normalizeLoginIdentityField(String raw) {
  final t = raw.trim();
  if (looksLikeEmailInput(t)) return t.toLowerCase();
  return t.replaceAll(RegExp(r'[\s\-\(\)]'), '');
}

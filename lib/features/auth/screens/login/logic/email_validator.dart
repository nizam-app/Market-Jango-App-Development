final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
bool isValidEmail(String s) => _emailRegex.hasMatch(s.trim());

String? emailValidator(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return 'Enter email';
  if (!isValidEmail(s)) return 'Enter a valid email';
  return null;
}
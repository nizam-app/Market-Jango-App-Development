final _passRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)\S{8,}$');
bool isValidPassword(String s) => _passRegex.hasMatch(s);
String? passwordValidator(String? v) {
  final s = (v ?? '');
  if (s.isEmpty) return 'Enter password';
  if (!_passRegex.hasMatch(s)) return 'Min 8 chars, include letter & number';
  return null;
}

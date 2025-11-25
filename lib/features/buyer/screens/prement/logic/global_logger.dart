// lib/core/debug/app_logger.dart
import 'package:logger/logger.dart';

final log = Logger(printer: PrettyPrinter(methodCount: 0));

String maskToken(String? t) {
  if (t == null || t.isEmpty) return '(empty)';
  if (t.length <= 8) return '****${t.substring(t.length - 2)}';
  return '${t.substring(0, 4)}****${t.substring(t.length - 4)}';
}
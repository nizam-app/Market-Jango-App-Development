import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedColorsProvider = StateProvider<List<String>>((ref) => []);
final selectedSizesProvider = StateProvider<List<String>>((ref) => []);
final productNameProvider = StateProvider<String>((ref) => '');
final productDescProvider = StateProvider<String>((ref) => '');
final productCategoryProvider = StateProvider<int?>((ref) => null);
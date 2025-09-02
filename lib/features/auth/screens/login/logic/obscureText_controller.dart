import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// password visibility state
final passwordVisibilityProvider = StateProvider<bool>((ref) => true);

// controller provider
final passwordControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});
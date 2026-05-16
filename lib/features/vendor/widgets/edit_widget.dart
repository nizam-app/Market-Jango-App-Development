import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/utils/get_user_type.dart';

import '../screens/product_edit/screen/product_edit_screen.dart';
import '../screens/vendor_home/model/vendor_product_model.dart';

class Edit_Widget extends ConsumerWidget {
  const Edit_Widget({
    super.key,
    required this.height,
    required this.width,
    required this.size,
    required this.product,
  });
  final double height;
  final double width;
  final double size;

  final VendorProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canProducts = ref.watch(canManageProductsProvider);
    final enabled = canProducts.valueOrNull ?? true;
    return GestureDetector(
      onTap: enabled ? () => editProductScreen(context) : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: ImageIcon(AssetImage("assets/icon/edit_ic.png"), size: size),
        ),
      ),
    );
  }

  void editProductScreen(BuildContext context) {
    context.push(ProductEditScreen.routeName, extra: product);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/screen/buyer_massage/data/offer_product_repository.dart';
import 'package:market_jango/core/screen/buyer_massage/model/chat_history_model.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/model/vendor_product_model.dart';

/// Custom input formatter for decimal numbers (allows digits and one decimal point)
class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty string
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Check if the new value contains only digits and at most one decimal point
    final regex = RegExp(r'^\d*\.?\d*$');
    if (regex.hasMatch(newValue.text)) {
      // Count decimal points
      final decimalCount = '.'.allMatches(newValue.text).length;
      if (decimalCount <= 1) {
        return newValue;
      }
    }

    // Reject the change if it doesn't match the pattern
    return oldValue;
  }
}

class CreateOfferSheet extends ConsumerStatefulWidget {
  const CreateOfferSheet({
    super.key,
    required this.product,
    required this.receiverId,
    this.onOfferCreated,
  });

  final VendorProduct product;
  final int receiverId;
  final Function(ChatMessage)? onOfferCreated;

  @override
  ConsumerState<CreateOfferSheet> createState() => _CreateOfferSheetState();
}

class _CreateOfferSheetState extends ConsumerState<CreateOfferSheet> {
  final _formKey = GlobalKey<FormState>();
  final _salePriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _deliveryChargeController = TextEditingController();
  final _colorController = TextEditingController();
  final _sizeController = TextEditingController();
  
  bool _isLoading = false;
  String? _selectedColor;
  String? _selectedSize;
  bool _useCustomColor = false;
  bool _useCustomSize = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill defaults
    final sellPrice = double.tryParse(widget.product.sellPrice) ?? 0.0;
    _salePriceController.text = sellPrice.toStringAsFixed(2);
    _quantityController.text = '1';
    _deliveryChargeController.text = '0';
    
    // Pre-select first available color/size if available
    if (widget.product.colors.isNotEmpty) {
      _selectedColor = widget.product.colors.first;
    } else {
      _useCustomColor = true;
    }
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes.first;
    } else {
      _useCustomSize = true;
    }
  }

  @override
  void dispose() {
    _salePriceController.dispose();
    _quantityController.dispose();
    _deliveryChargeController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _createOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check stock availability
    final stock = widget.product.stock;
    if (stock == null || stock <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This product is not available in stock'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Check if requested quantity exceeds available stock
    final requestedQuantity = int.tryParse(_quantityController.text) ?? 0;
    if (requestedQuantity > stock) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Only $stock item(s) available in stock. Please adjust your quantity.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = OfferProductRepository();
      // Get color and size values
      final colorValue = _useCustomColor 
          ? _colorController.text.trim() 
          : (_selectedColor ?? '');
      final sizeValue = _useCustomSize 
          ? _sizeController.text.trim() 
          : (_selectedSize ?? '');

      final chatMessage = await repository.createOffer(
        receiverId: widget.receiverId,
        productId: widget.product.id,
        salePrice: double.parse(_salePriceController.text),
        quantity: requestedQuantity,
        deliveryCharge: double.parse(_deliveryChargeController.text),
        color: colorValue,
        size: sizeValue,
      );

      if (mounted) {
        Navigator.of(context).pop();
        if (widget.onOfferCreated != null) {
          widget.onOfferCreated!(chatMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create offer: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product info header
              Row(
                children: [
                  if (widget.product.image.isNotEmpty)
                    ClipOval(
                      child: FirstTimeShimmerImage(
                        imageUrl: widget.product.image,
                        width: 60.w,
                        height: 60.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (widget.product.image.isEmpty)
                    Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: AllColor.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.image),
                    )
                  else
                    Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: AllColor.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.image),
                    ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Regular: ৳${widget.product.regularPrice}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                'Create Offer',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              
              // Sale Price
              TextFormField(
                controller: _salePriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  DecimalTextInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Sale Price (৳)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  prefixText: '৳ ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter sale price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Sale price must be greater than 0';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              
              // Quantity
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  final qty = int.tryParse(value);
                  if (qty == null || qty <= 0) {
                    return 'Quantity must be greater than 0';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              
              // Delivery Charge
              TextFormField(
                controller: _deliveryChargeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  DecimalTextInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Delivery Charge (৳)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  prefixText: '৳ ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter delivery charge';
                  }
                  final charge = double.tryParse(value);
                  if (charge == null || charge < 0) {
                    return 'Delivery charge must be 0 or greater';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              
              // Color Selection
              if (widget.product.colors.isNotEmpty && !_useCustomColor) ...[
                Text(
                  'Color',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    ...widget.product.colors.map((color) {
                      final isSelected = _selectedColor == color;
                      return ChoiceChip(
                        label: Text(color),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedColor = selected ? color : null;
                            _useCustomColor = false;
                          });
                        },
                      );
                    }),
                    ChoiceChip(
                      label: const Text('Custom'),
                      selected: _useCustomColor,
                      onSelected: (selected) {
                        setState(() {
                          _useCustomColor = selected;
                          _selectedColor = null;
                        });
                      },
                    ),
                  ],
                ),
                if (_useCustomColor) ...[
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _colorController,
                    decoration: InputDecoration(
                      labelText: 'Custom Color',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      hintText: 'e.g., black, red',
                    ),
                  ),
                ],
              ] else ...[
                TextFormField(
                  controller: _colorController,
                  decoration: InputDecoration(
                    labelText: 'Color',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    hintText: 'e.g., black, red',
                  ),
                ),
              ],
              SizedBox(height: 16.h),
              
              // Size Selection
              if (widget.product.sizes.isNotEmpty && !_useCustomSize) ...[
                Text(
                  'Size',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    ...widget.product.sizes.map((size) {
                      final isSelected = _selectedSize == size;
                      return ChoiceChip(
                        label: Text(size),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSize = selected ? size : null;
                            _useCustomSize = false;
                          });
                        },
                      );
                    }),
                    ChoiceChip(
                      label: const Text('Custom'),
                      selected: _useCustomSize,
                      onSelected: (selected) {
                        setState(() {
                          _useCustomSize = selected;
                          _selectedSize = null;
                        });
                      },
                    ),
                  ],
                ),
                if (_useCustomSize) ...[
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _sizeController,
                    decoration: InputDecoration(
                      labelText: 'Custom Size',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      hintText: 'e.g., XL, M, L',
                    ),
                  ),
                ],
              ] else ...[
                TextFormField(
                  controller: _sizeController,
                  decoration: InputDecoration(
                    labelText: 'Size',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    hintText: 'e.g., XL, M, L',
                  ),
                ),
              ],
              SizedBox(height: 24.h),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: BorderSide(color: AllColor.grey.shade300),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: CustomAuthButton(
                      buttonText: _isLoading ? 'Creating...' : 'Create Offer',
                      onTap: _isLoading ? () {} : _createOffer,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }
}


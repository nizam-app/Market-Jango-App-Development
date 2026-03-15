import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/transport/screens/booking_confirm/data/create_shipment_data.dart';
import 'package:market_jango/features/transport/screens/booking_confirm/transport_shipment_details_screen.dart';
import 'package:market_jango/features/transport/screens/driver/screen/driver_details_screen.dart';
import 'package:market_jango/features/transport/screens/driver/screen/model/transport_driver_model.dart';

/// Arguments passed when navigating to this screen (selected driver + optional pickup/destination/transportType).
class TransportBookingConfirmArgs {
  const TransportBookingConfirmArgs({
    required this.driver,
    this.pickup,
    this.destination,
    this.transportType,
  });

  final Driver driver;
  final String? pickup;
  final String? destination;
  /// API value: "motorcycle", "car", "air", "water"
  final String? transportType;
}

class TransportBookingConfirmScreen extends ConsumerStatefulWidget {
  const TransportBookingConfirmScreen({super.key, required this.args});

  final TransportBookingConfirmArgs args;
  static const String routeName = '/transport_booking_confirm';

  @override
  ConsumerState<TransportBookingConfirmScreen> createState() =>
      _TransportBookingConfirmScreenState();
}

class _TransportBookingConfirmScreenState
    extends ConsumerState<TransportBookingConfirmScreen> {
  /// One list of controllers per package: [length, width, height, pieces, weight, buildingShop, phone]
  final List<List<TextEditingController>> _packageControllers = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addPackage();
  }

  void _addPackage() {
    setState(() {
      _packageControllers.add([
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ]);
    });
  }

  void _removePackage(int index) {
    if (_packageControllers.length <= 1) return;
    for (final c in _packageControllers[index]) {
      c.dispose();
    }
    setState(() {
      _packageControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (final list in _packageControllers) {
      for (final c in list) {
        c.dispose();
      }
    }
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _createShipmentAndNavigate() async {
    final driver = widget.args.driver;
    final origin = widget.args.pickup?.trim();
    final destination = widget.args.destination?.trim();
    final packages = _packageControllers.map((list) {
      final length = double.tryParse(list.length > 0 ? list[0].text : '');
      final width = double.tryParse(list.length > 1 ? list[1].text : '');
      final height = double.tryParse(list.length > 2 ? list[2].text : '');
      final pieces = int.tryParse(list.length > 3 ? list[3].text : '1') ?? 1;
      final weight = double.tryParse(list.length > 4 ? list[4].text : '');
      return ShipmentPackageInput(
        lengthCm: length,
        widthCm: width,
        heightCm: height,
        weightKg: weight,
        quantity: pieces,
      );
    }).toList();

    final firstBuilding = _packageControllers.isNotEmpty && _packageControllers.first.length > 5
        ? _packageControllers.first[5].text.trim()
        : null;
    final firstPhone = _packageControllers.isNotEmpty && _packageControllers.first.length > 6
        ? _packageControllers.first[6].text.trim()
        : null;

    final request = CreateShipmentRequest(
      driverId: driver.id,
      transportType: widget.args.transportType?.isNotEmpty == true ? widget.args.transportType : null,
      originAddress: (origin != null && origin.isNotEmpty) ? origin : null,
      destinationAddress: (destination != null && destination.isNotEmpty) ? destination : null,
      pickupInstructions: firstBuilding?.isNotEmpty == true ? firstBuilding : null,
      pickupContactPhone: firstPhone?.isNotEmpty == true ? firstPhone : null,
      messageToDriver: _messageController.text.trim().isNotEmpty ? _messageController.text.trim() : null,
      packages: packages,
    );

    try {
      final token = await ref.read(authTokenProvider.future) ?? '';
      final result = await createShipment(token: token, request: request);
      if (!mounted) return;
      context.push(
        TransportShipmentDetailsScreen.routeName,
        extra: TransportShipmentDetailsArgs(result: result),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final driver = widget.args.driver;
    final user = driver.user;
    final avatarUrl = (user.image?.isNotEmpty == true)
        ? user.image!
        : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTxfenNzfIFlwE5dd7aduVOvGR05Qqz7EDi-Q&s';

    const Color cardBg = Color(0xFFFFFFFF);
    const Color surfaceLight = Color(0xFFF8FAFC);
    const Color textPrimary = Color(0xFF1E293B);
    const Color textSecondary = Color(0xFF64748B);
    const Color borderLight = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          ref.t(BKeys.create_package, fallback: 'Create package'),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            /// Driver card
            _sectionTitle(ref.t(BKeys.driver_information)),
            SizedBox(height: 10.h),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: FirstTimeShimmerImage(
                        imageUrl: avatarUrl,
                        width: 56.r,
                        height: 56.r,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              color: textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            user.phone,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: textSecondary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AllColor.blue500.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '${driver.carName} · \$${driver.price}/km',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AllColor.blue500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        context.push(
                          DriverDetailsScreen.routeName,
                          extra: user.id,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        side: BorderSide(color: borderLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        foregroundColor: textPrimary,
                      ),
                      child: Text(
                        ref.t(BKeys.see_details),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 28.h),
            /// Package list
            _sectionTitle(ref.t(BKeys.create_package, fallback: 'Create package')),
            SizedBox(height: 12.h),
            ...List.generate(_packageControllers.length, (index) {
              return _PackageCard(
                index: index,
                controllers: _packageControllers[index],
                canRemove: _packageControllers.length > 1,
                onRemove: () => _removePackage(index),
                onChanged: () => setState(() {}),
                ref: ref,
              );
            }),
            SizedBox(height: 12.h),
            InkWell(
              onTap: _addPackage,
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: surfaceLight,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: borderLight, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 22.sp,
                      color: AllColor.blue500,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      ref.t(BKeys.add_packages),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AllColor.blue500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 28.h),

            /// Message
            _sectionTitle(ref.t(BKeys.message_to_driver)),
            SizedBox(height: 10.h),
            TextField(
              controller: _messageController,
              maxLines: 4,
              style: TextStyle(fontSize: 14.sp, color: textPrimary),
              decoration: InputDecoration(
                hintText: ref.t(BKeys.message_to_driver),
                hintStyle: TextStyle(color: textSecondary, fontSize: 14.sp),
                filled: true,
                fillColor: cardBg,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: AllColor.blue500, width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 32.h),

            /// Create shipment
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createShipmentAndNavigate,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  backgroundColor: AllColor.blue500,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  ref.t(BKeys.create_shipment, fallback: 'Create shipment'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1E293B),
        letterSpacing: -0.2,
      ),
    );
  }
}

/// Single package form: dimensions, pieces, weight, pickup/contact, remove.
class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.index,
    required this.controllers,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
    required this.ref,
  });

  final int index;
  final List<TextEditingController> controllers;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final WidgetRef ref;

  static const Color _borderLight = Color(0xFFE2E8F0);
  static const Color _surfaceLight = Color(0xFFF8FAFC);
  static const Color _textPrimary = Color(0xFF1E293B);
  static const Color _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final lengthC = controllers.length > 0 ? controllers[0] : null;
    final widthC = controllers.length > 1 ? controllers[1] : null;
    final heightC = controllers.length > 2 ? controllers[2] : null;
    final piecesC = controllers.length > 3 ? controllers[3] : null;
    final weightC = controllers.length > 4 ? controllers[4] : null;
    final buildingC = controllers.length > 5 ? controllers[5] : null;
    final phoneC = controllers.length > 6 ? controllers[6] : null;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${ref.t(BKeys.create_package, fallback: 'Create package')} #${index + 1}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                if (canRemove)
                  InkWell(
                    onTap: onRemove,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18.sp,
                            color: const Color(0xFFDC2626),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            ref.t(BKeys.remove),
                            style: TextStyle(
                              color: const Color(0xFFDC2626),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _input(lengthC, ref.t(BKeys.length), hint: 'cm'),
                ),
                SizedBox(width: 10.w),
                Expanded(child: _input(widthC, ref.t(BKeys.width), hint: 'cm')),
                SizedBox(width: 10.w),
                Expanded(
                  child: _input(heightC, ref.t(BKeys.height), hint: 'cm'),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _input(
                    piecesC,
                    ref.t(BKeys.number_of_pieces),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _input(
                    weightC,
                    ref.t(BKeys.weight_kg),
                    hint: 'kg',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _input(buildingC, ref.t(BKeys.building_shop_number_name)),
            SizedBox(height: 10.h),
            _input(
              phoneC,
              ref.t(BKeys.phone_number),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController? controller,
    String label, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    if (controller == null) return const SizedBox.shrink();
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => onChanged(),
      style: TextStyle(fontSize: 14.sp, color: _textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: _textSecondary, fontSize: 13.sp),
        filled: true,
        fillColor: _surfaceLight,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AllColor.blue500, width: 1.5),
        ),
      ),
    );
  }
}

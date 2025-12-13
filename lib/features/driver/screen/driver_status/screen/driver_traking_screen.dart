import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/screen/google_map/data/location_store.dart';
import 'package:market_jango/core/screen/google_map/screen/google_map.dart';
import 'package:market_jango/core/screen/profile_screen/screen/global_profile_edit_screen.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/global_locaiton_button.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/driver/screen/driver_order/model/driver_order_details_model.dart';
import 'package:market_jango/features/driver/screen/driver_status/logic/driver_status_update.dart';
import 'package:market_jango/features/driver/screen/driver_status/model/status_ui_model.dart';

import '../../driver_order/data/driver_order_details_data.dart';

class DriverTrakingScreen extends ConsumerWidget {
  const DriverTrakingScreen({super.key, required this.trackingId});

  static const routeName = "/driverTrackingScreen";
  final String trackingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.tryParse(trackingId) ?? 0;
    final trackingAsync = ref.watch(driverTrackingStatusProvider(id));
    final service = ref.read(driverTrackingServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: trackingAsync.when(
          // ...
          data: (data) {
            final ui = buildTrackingUi(data);
            final canConfirm =
                ui.editableStep == TrackingStep.confirmDelivery &&
                (!ui.showCashStep ||
                    ui.cashChecked); // 🔥 OPU হলে cash না হলে confirm বন্ধ

            return Column(
              children: [
                const CustomBackButton(),
                const SizedBox(height: 8),
                _Header(image: data.user?.image ?? ""),
                const SizedBox(height: 12),

                // 3 step (Pending / On The Way / Complete)
                _ProgressStepper(
                  currentStep: ui.currentStep,
                  totalSteps: ui.showCashStep ? 4 : 3, // 🔥 OPU hole 4 step
                ),

                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TrackingNumberCard(
                          number: data.invoice?.taxRef ?? data.tranId,
                        ),
                        const SizedBox(height: 16),

                        // ---------- 1) Packed ----------
                        _StatusTile(
                          checked: ui.packedChecked,
                          //Picked
                          title: ref.t(BKeys.picked),
                          time: _formatTime(data.createdAt),
                          body: ui.packedNote ?? '',
                          editable: ui.editableStep == TrackingStep.packed,
                          onBadgeTap: ui.editableStep == TrackingStep.packed
                              ? () => _handleNotDeliver(
                                  context,
                                  ref,
                                  id,
                                  service,
                                  data,
                                )
                              : null,
                          onChanged: ui.editableStep == TrackingStep.packed
                              ? (_) => _handlePackedDone(
                                  context,
                                  ref,
                                  id,
                                  service,
                                  data,
                                )
                              : null,
                          onTap: ui.editableStep == TrackingStep.packed
                              ? () => _handlePackedDone(
                                  context,
                                  ref,
                                  id,
                                  service,
                                  data,
                                )
                              : null,
                        ),

                        const SizedBox(height: 10),

                        // // ---------- 1) Packed (same as before) ----------
                        // _StatusTile(
                        //   checked: ui.packedChecked,
                        //   title: 'Packed',
                        //   time: _formatTime(data.createdAt),
                        //   body: ui.packedNote ?? '',
                        //   editable: ui.editableStep == TrackingStep.packed,
                        //   onBadgeTap: ui.editableStep == TrackingStep.packed
                        //       ? () => _handleNotDeliver(
                        //           context,
                        //           ref,
                        //           id,
                        //           service,
                        //           data,
                        //         )
                        //       : null,
                        //   onChanged: ui.editableStep == TrackingStep.packed
                        //       ? (_) => _handlePackedDone(
                        //           context,
                        //           ref,
                        //           id,
                        //           service,
                        //           data,
                        //         )
                        //       : null,
                        //   onTap: ui.editableStep == TrackingStep.packed
                        //       ? () => _handlePackedDone(
                        //           context,
                        //           ref,
                        //           id,
                        //           service,
                        //           data,
                        //         )
                        //       : null,
                        // ),
                        //
                        // const SizedBox(height: 10),

                        // ---------- 2) Cash Receive (only for OPU / showCashStep) ----------
                        if (ui.showCashStep) ...[
                          _StatusTile(
                            checked: ui.cashChecked,
                            title: 'Cash Receive',
                            time: _formatTime(data.updatedAt),
                            body: ui.cashNote ?? '',
                            editable:
                                ui.editableStep == TrackingStep.cashReceive,
                            onChanged:
                                ui.editableStep == TrackingStep.cashReceive
                                ? (_) => _handleCashReceive(
                                    context,
                                    ref,
                                    id,
                                    service,
                                    data,
                                  )
                                : null,
                            onTap: ui.editableStep == TrackingStep.cashReceive
                                ? () => _handleCashReceive(
                                    context,
                                    ref,
                                    id,
                                    service,
                                    data,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 10),
                        ],

                        // ---------- 3) Confirm Delivery ----------
                        _StatusTile(
                          checked: ui.confirmChecked,
                          title: 'Confirm Delivery',
                          time: _formatTime(data.updatedAt),
                          body: ui.confirmNote ?? '',
                          editable: canConfirm,
                          onBadgeTap: canConfirm
                              ? () => _handleNotDeliver(
                                  context,
                                  ref,
                                  id,
                                  service,
                                  data,
                                )
                              : null,
                          onChanged: canConfirm
                              ? (_) => _handleComplete(
                                  context,
                                  ref,
                                  id,
                                  service,
                                  data,
                                )
                              : null,
                          onTap: canConfirm
                              ? () => _handleComplete(
                                  context,
                                  ref,
                                  id,
                                  service,
                                  data,
                                )
                              : null,
                        ),

                        // ---------- 3) Cancel (Not Deliver) ----------
                        if (!ui.confirmChecked) ...[
                          const SizedBox(height: 10),
                          _StatusTile(
                            checked: ui.cancelChecked,
                            title: 'Cancel',
                            time: _formatTime(data.updatedAt),
                            body: ui.cancelNote ?? '',
                            editable: ui.showCancel,
                            onBadgeTap: null,
                            onChanged: ui.showCancel
                                ? (_) => _handleNotDeliver(
                                    context,
                                    ref,
                                    id,
                                    service,
                                    data,
                                  )
                                : null,
                            onTap: ui.showCancel
                                ? () => _handleNotDeliver(
                                    context,
                                    ref,
                                    id,
                                    service,
                                    data,
                                  )
                                : null,
                          ),
                        ],
                        // ...
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: Text('Loading...')),
          error: (e, _) => Center(child: Text(e.toString())),
        ),
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d  $h:$min';
  }

  Future<void> _handleCashReceive(
    BuildContext context,
    WidgetRef ref,
    int trackingId,
    DriverTrackingService service,
    DriverTrackingData data,
  ) async {
    final result = await _showCashReceiveDialog(
      context,
      initialNote: data.note,
    );

    if (result == null) return;

    final note = result['note']!.trim();
    final proofId = result['payment_proof_id']!.trim();

    if (note.isEmpty || proofId.isEmpty) {
      _showError(context, 'Note এবং Payment proof ID দুটোই লাগবে।');
      return;
    }

    try {
      await service.updateStatus(
        id: data.id,
        status: 'Ready for delivery',
        note: note,
        paymentProofId: proofId,
      );

      // fresh data
      ref.invalidate(driverTrackingStatusProvider(trackingId));

      _showError(context, 'Cash received, status "Ready for delivery".');
    } catch (e) {
      _showError(context, e.toString());
    }
  }
}

Future<Map<String, String>?> _showCashReceiveDialog(
  BuildContext context, {
  String? initialNote,
}) {
  final noteCtrl = TextEditingController(text: initialNote ?? '');
  final proofCtrl = TextEditingController();

  return showDialog<Map<String, String>>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          'Cash Receive',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Note *',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AllColor.textHintColor,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Cash receive note...',
                  filled: true,
                  fillColor: AllColor.grey100,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AllColor.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AllColor.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AllColor.blue500, width: 1.4),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Payment proof ID *',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AllColor.textHintColor,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              TextField(
                controller: proofCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 65452145211',
                  filled: true,
                  fillColor: AllColor.grey100,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AllColor.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AllColor.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AllColor.blue500, width: 1.4),
                  ),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: EdgeInsets.only(bottom: 8.h, right: 8.w),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AllColor.blue500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              Navigator.pop<Map<String, String>>(ctx, {
                'note': noteCtrl.text.trim(),
                'payment_proof_id': proofCtrl.text.trim(),
              });
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.image});
  final String image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AllColor.blue200,
            backgroundImage: NetworkImage(image),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To Recieve',
                style: TextStyle(
                  color: AllColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Track Your Order',
                style: TextStyle(
                  color: AllColor.textHintColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _ProgressStepper({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    const trackLeft = 24.0, trackRight = 24.0;
    final usable = w - (trackLeft + trackRight);
    final segment = usable / (totalSteps - 1);
    final progressW = (currentStep - 1) * segment;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 42,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background track
            Positioned(
              left: trackLeft,
              right: trackRight,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AllColor.grey200,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            // Progress bar
            Positioned(
              left: trackLeft,
              child: Container(
                width: progressW,
                height: 6,
                decoration: BoxDecoration(
                  color: AllColor.blue500,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            // Dynamic dots (Spread operator ব্যবহার করা হয়েছে)
            ...List.generate(totalSteps, (i) {
              return Positioned(
                left: trackLeft - 8 + i * segment,
                child: _stepDot(active: currentStep >= (i + 1)),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _stepDot({required bool active}) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: active ? AllColor.blue500 : AllColor.blue200,
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? AllColor.blue500 : AllColor.grey200,
          width: 2,
        ),
      ),
    );
  }
}

class _TrackingNumberCard extends StatelessWidget {
  final String number;
  const _TrackingNumberCard({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AllColor.blue50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AllColor.grey200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tracking Number',
                  style: TextStyle(
                    color: AllColor.textHintColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  number,
                  style: TextStyle(
                    color: AllColor.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: number));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Copied: $number')));
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AllColor.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AllColor.grey200),
              ),
              child: Icon(
                Icons.copy_rounded,
                color: AllColor.blue500,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatefulWidget {
  final bool checked; // initial value
  final String title;
  final String time;
  final String body;

  /// এই row কি editable? (tick + note edit শুধুই এইটার জন্য অন)
  final bool editable;

  /// note edit icon / পুরো tile tap
  final VoidCallback? onTap;

  // final String? badgeText; // e.g. "Not Delivery"
  final VoidCallback? onBadgeTap;
  final Color? badgeColor;

  /// checkbox change
  final ValueChanged<bool>? onChanged;

  const _StatusTile({
    required this.checked,
    required this.title,
    required this.time,
    required this.body,
    this.editable = false,
    this.onTap,
    // this.badgeText,
    this.onBadgeTap,
    this.badgeColor,
    this.onChanged,
  });

  @override
  State<_StatusTile> createState() => _StatusTileState();
}

class _StatusTileState extends State<_StatusTile> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.checked;
  }

  @override
  void didUpdateWidget(covariant _StatusTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // parent থেকে checked পরিবর্তন হলে লোকাল স্টেট sync করবে
    if (oldWidget.checked != widget.checked) {
      _checked = widget.checked;
    }
  }

  void _toggle() {
    if (!widget.editable) return; // শুধু editable হলে কাজ করবে
    setState(() => _checked = !_checked);
    widget.onChanged?.call(_checked);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AllColor.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.editable ? widget.onTap : null,
        child: Container(
          decoration: BoxDecoration(
            color: AllColor.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AllColor.grey200),
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggle,
                    child: _CheckSquare(checked: _checked),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: AllColor.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    widget.time,
                    style: TextStyle(
                      color: AllColor.textHintColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.editable) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: widget.onTap,
                      child: Icon(
                        Icons.edit_note,
                        color: AllColor.blue500,
                        size: 22,
                      ),
                    ),
                  ],
                ],
              ),
              if (widget.body.isNotEmpty) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    widget.body,
                    style: TextStyle(color: AllColor.black54, height: 1.35),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// class _StatusTileState extends State<_StatusTile> {
//   late bool _checked;
//
//   @override
//   void initState() {
//     super.initState();
//     _checked = widget.checked;
//   }
//
//   void _toggle() {
//     setState(() => _checked = !_checked);
//     widget.onChanged?.call(_checked);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: AllColor.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: widget.onTap,
//         child: Container(
//           decoration: BoxDecoration(
//             color: AllColor.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: AllColor.grey200),
//           ),
//           padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Title row
//               Row(
//                 children: [
//                   GestureDetector(
//                     behavior: HitTestBehavior.opaque,
//                     onTap: _toggle,
//                     child: _CheckSquare(checked: _checked),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       widget.title,
//                       style: TextStyle(
//                         color: AllColor.black,
//                         fontSize: 15,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                   Text(
//                     widget.time,
//                     style: TextStyle(
//                       color: AllColor.textHintColor,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 6),
//               Padding(
//                 padding: const EdgeInsets.only(left: 6),
//                 child: Text(
//                   widget.body,
//                   style: TextStyle(color: AllColor.black54, height: 1.35),
//                 ),
//               ),
//               if (widget.badgeText != null) ...[
//                 const SizedBox(height: 10),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 6),
//                   child: GestureDetector(
//                     onTap: widget.onBadgeTap, // ব্যাজে ট্যাপ -> GoRouter
//                     child: _Badge(
//                       text: widget.badgeText!,
//                       color:
//                           widget.badgeColor ??
//                           AllColor.loginButtomColor, // <- color override
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _CheckSquare extends StatelessWidget {
  final bool checked;
  const _CheckSquare({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: checked ? AllColor.blue500 : AllColor.white,
        border: Border.all(color: AllColor.blue500, width: 1.6),
      ),
      child: checked
          ? Icon(Icons.check, size: 16, color: AllColor.white)
          : null,
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _CustomerInfoCard extends StatelessWidget {
  final String name;
  final String phone;
  const _CustomerInfoCard({required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AllColor.grey200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AllColor.blue200,
            child: Text(
              'J',
              style: TextStyle(
                color: AllColor.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AllColor.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: TextStyle(color: AllColor.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _RoundIcon(
            icon: Icons.chat,
            bg: AllColor.dropDown,
            fg: AllColor.green500,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _RoundIcon(
            icon: Icons.call,
            bg: AllColor.dropDown,
            fg: AllColor.green500,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  const _RoundIcon({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: fg, size: 20),
        ),
      ),
    );
  }
}

Future<String?> _showNoteDialog(BuildContext context, {String? initial}) async {
  final controller = TextEditingController(text: initial ?? '');

  return showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          'Add Note',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write note here...',
              filled: true,
              fillColor: AllColor.grey100,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: AllColor.grey300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: AllColor.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: AllColor.blue500, width: 1.4),
              ),
            ),
          ),
        ),
        actionsPadding: EdgeInsets.only(bottom: 8.h, right: 8.w),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AllColor.blue500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx, controller.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

void _showError(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

/// Packed step complete -> status = "On The Way"
/// Packed step complete -> status = "On The Way"
Future<void> _handlePackedDone(
  BuildContext context,
  WidgetRef ref,
  int trackingId,
  DriverTrackingService service,
  DriverTrackingData data,
) async {
  final note = await _showNoteDialog(context, initial: data.note);
  if (note == null || note.isEmpty) {
    _showError(context, 'Please add a note.');
    return;
  }

  try {
    await service.updateStatus(id: data.id, status: 'On The Way', note: note);

    // 🔥 API সফল হলে fresh data আনো
    ref.invalidate(driverTrackingStatusProvider(trackingId));

    _showError(context, 'Status updated to "On The Way".');
  } catch (e) {
    _showError(context, e.toString());
  }
}

/// Confirm Delivery -> status = "Complete"
/// Confirm Delivery -> status = "Complete"
Future<void> _handleComplete(
  BuildContext context,
  WidgetRef ref,
  int trackingId,
  DriverTrackingService service,
  DriverTrackingData data,
) async {
  final note = await _showNoteDialog(context, initial: data.note);
  if (note == null || note.isEmpty) {
    _showError(context, 'Please add a note.');
    return;
  }

  try {
    await service.updateStatus(id: data.id, status: 'Complete', note: note);

    // 🔥 Re-fetch tracking data
    ref.invalidate(driverTrackingStatusProvider(trackingId));

    _showError(context, 'Delivery completed.');
  } catch (e) {
    _showError(context, e.toString());
  }
}

Future<void> _handleNotDeliver(
  BuildContext context,
  WidgetRef ref,
  int trackingId,
  DriverTrackingService service,
  DriverTrackingData data,
) async {
  final result = await showNotDeliveryBottomSheet(
    context,
    initialNote: data.note,
    initialAddress: data.currentAddress,
  );

  String? note;
  double? lat;
  double? lng;
  String? address;

  if (result is Map<String, dynamic>) {
    note = result['note']?.toString();
    lat = (result['lat'] as num?)?.toDouble();
    lng = (result['lng'] as num?)?.toDouble();
    address = result['address']?.toString();
  } else if (result is String) {
    note = result;
  }

  if (note == null || note.trim().isEmpty) {
    _showError(context, 'Note is required for Not Deliver.');
    return;
  }

  try {
    await service.updateStatus(
      id: data.id,
      status: 'Not Deliver',
      note: note,
      currentLatitude: lat,
      currentLongitude: lng,
      currentAddress: address ?? data.currentAddress,
    );

    // 🔥 Status Not Deliver হলে UI refresh
    ref.invalidate(driverTrackingStatusProvider(trackingId));

    _showError(context, 'Status updated to "Not Deliver".');
  } catch (e) {
    _showError(context, e.toString());
  }
}

Future<Map<String, dynamic>?> showNotDeliveryBottomSheet(
  BuildContext context, {
  String? initialNote,
  String? initialAddress,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final bottom = MediaQuery.of(ctx).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: _NotDeliverSheet(
          initialNote: initialNote,
          initialAddress: initialAddress,
        ),
      );
    },
  );
}

class _NotDeliverSheet extends ConsumerStatefulWidget {
  final String? initialNote;
  final String? initialAddress;

  const _NotDeliverSheet({this.initialNote, this.initialAddress});

  @override
  ConsumerState<_NotDeliverSheet> createState() => _NotDeliverSheetState();
}

class _NotDeliverSheetState extends ConsumerState<_NotDeliverSheet> {
  final _noteCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  double? _backupLat;
  double? _backupLng;

  @override
  void initState() {
    super.initState();
    _noteCtrl.text = widget.initialNote ?? '';
    _addressCtrl.text = widget.initialAddress ?? '';
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final note = _noteCtrl.text.trim();
    if (note.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: "Error",
        message: "Note is required.",
        type: CustomSnackType.error,
      );
      return;
    }

    final lat = ref.read(selectedLatitudeProvider) ?? _backupLat;
    final lng = ref.read(selectedLongitudeProvider) ?? _backupLng;

    Navigator.of(context).pop(<String, dynamic>{
      'note': note,
      'lat': lat,
      'lng': lng,
      'address': _addressCtrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AllColor.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                'Cancel / Not Deliver',
                style: TextStyle(
                  color: AllColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Reason (note)*',
                style: TextStyle(
                  color: AllColor.textHintColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write why you cannot deliver...',
                  filled: true,
                  fillColor: AllColor.grey100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AllColor.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AllColor.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AllColor.blue500),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Current address (optional)',
                style: TextStyle(
                  color: AllColor.textHintColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter your Address...',
                  filled: true,
                  fillColor: AllColor.grey100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AllColor.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AllColor.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AllColor.blue500),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// 🔥 Location button – এইখানে তোমার দেওয়া কোডটাই ব্যবহার করা হয়েছে
              LocationButton(
                onTap: () async {
                  final currentLat =
                      ref.read(selectedLatitudeProvider) ?? _backupLat;
                  final currentLng =
                      ref.read(selectedLongitudeProvider) ?? _backupLng;

                  LatLng? initialLocation;
                  if (currentLat != null && currentLng != null) {
                    initialLocation = LatLng(currentLat, currentLng);
                  }

                  final result = await context.push<LatLng>(
                    GoogleMapScreen.routeName,
                    extra: initialLocation,
                  );

                  if (result != null) {
                    ref.read(selectedLatitudeProvider.notifier).state =
                        result.latitude;
                    ref.read(selectedLongitudeProvider.notifier).state =
                        result.longitude;

                    TempLocationStorage.setLocation(
                      result.latitude,
                      result.longitude,
                    );

                    setState(() {
                      _backupLat = result.latitude;
                      _backupLng = result.longitude;
                    });

                    GlobalSnackbar.show(
                      context,
                      title: "Success",
                      message: "Location selected successfully!",
                      type: CustomSnackType.success,
                    );
                  }
                },
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AllColor.grey300),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomAuthButton(
                      onTap: _submit,
                      buttonText: 'Confirm',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

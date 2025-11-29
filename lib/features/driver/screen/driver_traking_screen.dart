import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/features/driver/widgets/bottom_sheet.dart';

import 'driver_order/data/driver_order_details_data.dart';

class DriverTrakingScreen extends ConsumerWidget {
  const DriverTrakingScreen({super.key, required this.trackingId});

  static final routeName = "/driverTrackingScreen";
  final String trackingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.parse(trackingId);
    final trackingAsync = ref.watch(driverTrackingProvider(id));
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomBackButton(),
            const SizedBox(height: 8),
            const _Header(),
            const SizedBox(height: 12),
            const _ProgressStepper(currentStep: 3, totalSteps: 3),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TrackingNumberCard(number: 'LGS-192827839300763731'),
                    const SizedBox(height: 16),

                    // ======= Clickable status rows =======
                    _StatusTile(
                      checked: true,
                      title: 'Packed',
                      time: 'April,19 12:31',
                      body:
                          'Lorem ipsum dolor sit amet, consectetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore.',
                      onTap: () {},
                      badgeText: 'Not Delivery',
                      onBadgeTap: () {},
                    ),

                    const SizedBox(height: 10),
                    _StatusTile(
                      checked: false,
                      title: 'Out for Delivery',
                      time: 'April,19 12:31',
                      body:
                          'Lorem ipsum dolor sit amet, consectetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore.',
                      onTap: () {},
                      badgeText: 'Not Delivery',
                      onBadgeTap: () {},
                    ),

                    const SizedBox(height: 10),
                    _StatusTile(
                      checked: true,
                      title: 'Confirm Delivery',
                      time: 'April,19 12:31',
                      body:
                          'Lorem ipsum dolor sit amet, consectetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore.',
                      onTap: () {},
                      badgeText: 'Not Delivery',
                      onBadgeTap: () async {
                        final result = await showNotDeliveryBottomSheet(
                          context,
                        );
                        if (result != null) {
                          print("User selected: $result");
                        }
                      },
                    ),

                    const SizedBox(height: 18),
                    Text(
                      'Customer information',
                      style: TextStyle(
                        color: AllColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _CustomerInfoCard(
                      name: 'Mr John Doe',
                      phone: '01780053624',
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AllColor.blue200,
            backgroundImage: NetworkImage(
              "https://randomuser.me/api/portraits/women/68.jpg",
            ),
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

  final VoidCallback onTap;

  final String? badgeText;
  final VoidCallback? onBadgeTap;

  final Color? badgeColor;

  final ValueChanged<bool>? onChanged;

  const _StatusTile({
    required this.checked,
    required this.title,
    required this.time,
    required this.body,
    required this.onTap,
    this.badgeText,
    this.onBadgeTap,
    this.badgeColor,
    this.onChanged,
    super.key,
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

  void _toggle() {
    setState(() => _checked = !_checked);
    widget.onChanged?.call(_checked);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AllColor.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
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
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  widget.body,
                  style: TextStyle(color: AllColor.black54, height: 1.35),
                ),
              ),
              if (widget.badgeText != null) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: GestureDetector(
                    onTap: widget.onBadgeTap, // ব্যাজে ট্যাপ -> GoRouter
                    child: _Badge(
                      text: widget.badgeText!,
                      color:
                          widget.badgeColor ??
                          AllColor.loginButtomColor, // <- color override
                    ),
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';

class VendorDriverList extends StatefulWidget {
  const VendorDriverList({super.key});
  static const routeName = "/vendorDriverList";

  @override
  State<VendorDriverList> createState() => _VendorDriverListState();
}

class _VendorDriverListState extends State<VendorDriverList> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _drivers.where((d) {
      final q = _search.text.trim().toLowerCase();
      if (q.isEmpty) return true;
      return d.name.toLowerCase().contains(q) || d.phone.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AllColor.white,

      body: SafeArea(
        child: Column(
          children: [
            CustomBackButton(),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search you transporter',
                  hintStyle: TextStyle(color: AllColor.textHintColor),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AllColor.black54,
                  ),
                  filled: true,
                  fillColor: AllColor.grey100,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: AllColor.grey200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: AllColor.grey200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: AllColor.blue500),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                physics: const BouncingScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _DriverCard(
                  data: filtered[i],
                  onAssign: () {

                    //
                    context.push("/assign_order_driver");
                    
                  },
                  onChat: () {
                    // context.go('/chat?to=${filtered[i].id}');
                    
                    context.push("/vendorTransportDetails");
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== MODEL & DEMO DATA ===================== */

class DriverItem {
  final String id;
  final String name;
  final String phone;
  final String address;
  final double price;
  final String avatarUrl;
  final bool online;
  const DriverItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.price,
    required this.avatarUrl,
    required this.online,
  });
}

const _drivers = <DriverItem>[
  DriverItem(
    id: '1',
    name: 'Nguyen, Shane',
    phone: '+00123456789',
    address: 'australia, road 19 house 1',
    price: 48,
    avatarUrl:
        'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=300',
    online: true,
  ),
  DriverItem(
    id: '2',
    name: 'Henry, Arthur',
    phone: '+00123456789',
    address: 'australia, road 19 house 1',
    price: 48,
    avatarUrl:
        'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=301',
    online: true,
  ),
  DriverItem(
    id: '3',
    name: 'Cooper, Kristin',
    phone: '+00123456789',
    address: 'australia, road 19 house 1',
    price: 48,
    avatarUrl:
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=300',
    online: true,
  ),
  DriverItem(
    id: '4',
    name: 'Black, Marvin',
    phone: '+00123456789',
    address: 'australia, road 19 house 1',
    price: 48,
    avatarUrl:
        'https://images.unsplash.com/photo-1544006659-f0b21884ce1d?w=300',
    online: true,
  ),
  DriverItem(
    id: '5',
    name: 'Miles, Esther',
    phone: '+00123456789',
    address: 'australia, road 19 house 1',
    price: 48,
    avatarUrl:
        'https://images.unsplash.com/photo-1548142813-c348350df52b?w=300',
    online: true,
  ),
];

/* ===================== CARD WIDGET ===================== */

class _DriverCard extends StatelessWidget {
  final DriverItem data;
  final VoidCallback onAssign;
  final VoidCallback onChat;

  const _DriverCard({
    required this.data,
    required this.onAssign,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final onlineColor = Colors.green;

    return Container(
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AllColor.grey200),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 60.h,
                  width: 60.w,
                  color: AllColor.grey100,
                  child: Image.network(data.avatarUrl, fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 10.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Online pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data.name,
                            style: TextStyle(
                              color: AllColor.black,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (data.online)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.h,
                              vertical: 5.w,
                            ),
                            decoration: BoxDecoration(
                              color: onlineColor.withOpacity(.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: onlineColor),
                            ),
                            child: Text(
                              'Online',
                              style: TextStyle(
                                color: onlineColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.phone,
                          style: TextStyle(color: AllColor.black54),
                        ),
                        Text(
                          '\$${data.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: AllColor.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      data.address,
                      style: TextStyle(color: AllColor.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10.h),

                  ],
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 36.h,
                child: ElevatedButton(
                  onPressed: onAssign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AllColor.loginButtomColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.h),
                  ),
                  child: Text(
                    'Assign to order',
                    style: TextStyle(
                      color: AllColor.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 40.h,
                width: 40.w,
                child: Material(
                  color: AllColor.blue500,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onChat,
                    child: Icon(
                      Icons.chat,
                      size: 20.sp,
                      color: AllColor.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
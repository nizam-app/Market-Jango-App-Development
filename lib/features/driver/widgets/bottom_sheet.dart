import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';


Future<String?> showNotDeliveryBottomSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: AllColor.white,
    barrierColor: Colors.black.withOpacity(.35),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const Bottom_Sheet(),
  );
}

class Bottom_Sheet extends StatefulWidget {
  const Bottom_Sheet({super.key}); 
  
 


  @override
  State<Bottom_Sheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<Bottom_Sheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your location')),
      );
      return;
    }
   context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // grabber
           SizedBox(height: 8.h),
          Container(
            height: 5.h,
            width: 60.w,
            decoration: BoxDecoration(
              color: AllColor.grey200,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
           SizedBox(height: 15.h),

          // content
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Delivery was not successful',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AllColor.black,
                  ),
                ),
                 SizedBox(height: 16.h),

                // Label
                Text(
                  'Enter your current location?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AllColor.black,
                  ),
                ),
                 SizedBox(height: 10.h),

                // TextField (rounded, light yellow bg, orange stroke)
                TextField(
                  controller: _ctrl,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  style: TextStyle(color: AllColor.black87, fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Enter your Location',
                    hintStyle: TextStyle(color: AllColor.textHintColor),
                    filled: true,
                    fillColor: AllColor.yellow50,
                    contentPadding:
                         EdgeInsets.symmetric(horizontal: 18.h, vertical: 14.w),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          BorderSide(color: AllColor.textBorderColor, width: 1.3),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          BorderSide(color: AllColor.yellow500, width: 1.6),
                    ),
                  ),
                ),

                 SizedBox(height: 16.h),
                Center(
                  child: SizedBox(
                    height: 42.h,
                    width: 140.w,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AllColor.loginButtomColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: AllColor.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                 SizedBox(height: 30.h),
              ],
            ),
          ),
          // bottom safe padding
           SizedBox(height: 40.h),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';

class VendorRoleGuard extends ConsumerWidget {
  const VendorRoleGuard({
    super.key,
    required this.allowedProvider,
    required this.child,
    this.title = 'Access denied',
    this.message = 'You do not have permission to access this feature.',
  });

  final FutureProvider<bool> allowedProvider;
  final Widget child;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(allowedProvider);
    return allowed.when(
      data: (ok) => ok ? child : _Denied(title: title, message: message),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _Denied(title: title, message: message),
    );
  }
}

class _Denied extends StatelessWidget {
  const _Denied({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 44.r, color: Colors.grey),
              SizedBox(height: 10.h),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, height: 1.35),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AllColor.orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () => context.pop(),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


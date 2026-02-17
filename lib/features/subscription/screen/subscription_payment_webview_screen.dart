import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// In-app WebView for subscription payment (Flutterwave).
/// Loads [paymentUrl]; on success/fail redirect, pops with true/false.
class SubscriptionPaymentWebViewScreen extends StatefulWidget {
  const SubscriptionPaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    this.planName,
  });

  final String paymentUrl;
  final String? planName;

  @override
  State<SubscriptionPaymentWebViewScreen> createState() =>
      _SubscriptionPaymentWebViewScreenState();
}

class _SubscriptionPaymentWebViewScreenState
    extends State<SubscriptionPaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _loadError = false;
  String? _errorMessage;

  static bool _isSuccessRedirect(String url) {
    final u = url.toLowerCase();
    return u.contains('subscription/success') ||
        u.contains('status=success') ||
        (Uri.tryParse(url)?.queryParameters['status'] ?? '').toLowerCase() == 'success';
  }

  static bool _isFailRedirect(String url) {
    final u = url.toLowerCase();
    return u.contains('subscription/failed') ||
        u.contains('subscription/fail') ||
        u.contains('status=fail') ||
        u.contains('status=cancel');
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;
            if (_isSuccessRedirect(url)) {
              if (mounted) Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            if (_isFailRedirect(url)) {
              if (mounted) Navigator.of(context).pop(false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (details) {
            final url = details.url ?? '';
            if (_isSuccessRedirect(url) && mounted) {
              Navigator.of(context).pop(true);
              return;
            }
            if (_isFailRedirect(url) && mounted) {
              Navigator.of(context).pop(false);
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _loading = false;
                _loadError = true;
                _errorMessage = error.description.isNotEmpty
                    ? error.description
                    : 'Could not load the payment page.';
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColor.white,
      appBar: AppBar(
        title: Text(
          widget.planName != null
              ? 'Pay – ${widget.planName}'
              : 'Complete payment',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AllColor.white,
        foregroundColor: AllColor.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          if (!_loadError) WebViewWidget(controller: _controller),
          if (_loadError)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 48.sp,
                      color: AllColor.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Couldn't connect to the server",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AllColor.black87,
                      ),
                    ),
                    if (_errorMessage != null && _errorMessage!.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AllColor.grey,
                        ),
                      ),
                    ],
                    SizedBox(height: 24.h),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _loadError = false;
                          _loading = true;
                        });
                        _controller.loadRequest(Uri.parse(widget.paymentUrl));
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AllColor.orange,
                        foregroundColor: AllColor.white,
                      ),
                      child: const Text('Retry'),
                    ),
                    SizedBox(height: 12.h),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
          if (_loading && !_loadError)
            Container(
              color: AllColor.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 32.w,
                      height: 32.h,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Loading payment…',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AllColor.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

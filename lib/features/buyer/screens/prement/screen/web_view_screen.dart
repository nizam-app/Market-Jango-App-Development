// lib/features/buyer/screens/prement/screen/web_view_screen.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:market_jango/features/buyer/screens/prement/logic/status_check_logic.dart';
import 'package:market_jango/features/buyer/screens/prement/model/prement_line_items.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  const PaymentWebView({super.key, required this.url});
  final String url;

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _c;
  bool _finished = false;
  bool _verifying = false;
  bool _showWebView = true; // Control WebView visibility

  final successHints = const [
    'success',
    'complete',
    'paid',
    'payment/success',
    'successful',
  ];

  @override
  void initState() {
    super.initState();
    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (req) {
            // Intercept payment response URLs BEFORE they load
            final uri = Uri.tryParse(req.url);
            final isPaymentResponse = uri != null && 
                (uri.path.contains('/api/payment/response') ||
                 req.url.toLowerCase().contains('/payment/response'));
            
            if (isPaymentResponse) {
              // Prevent navigation to payment response URL
              // Hide WebView and show loading immediately
              setState(() {
                _showWebView = false;
              });
              // Verify payment without loading the URL
              _confirmAndClose(callback: uri);
              return NavigationDecision.prevent;
            }
            
            // Allow navigation for other URLs
            _maybeVerifyByUrl(req.url);
            return NavigationDecision.navigate;
          },
          onUrlChange: (c) {
            // Also check URL changes (in case navigation request doesn't catch it)
            final uri = Uri.tryParse(c.url ?? '');
            final isPaymentResponse = uri != null && 
                (uri.path.contains('/api/payment/response') ||
                 (c.url ?? '').toLowerCase().contains('/payment/response'));
            
            if (isPaymentResponse && !_verifying && !_finished) {
              setState(() {
                _showWebView = false;
              });
              _confirmAndClose(callback: uri);
            } else {
              _maybeVerifyByUrl(c.url);
            }
          },
          onPageFinished: (_) {
            if (!_verifying && !_finished) {
              _inspectDom();
            }
          },
          onWebResourceError: (error) {
            // Handle cleartext HTTP errors and other loading errors
            if (error.errorCode == -2 || // ERR_FAILED
                (error.description?.contains('ERR_CLEARTEXT_NOT_PERMITTED') == true) ||
                (error.description?.contains('cleartext') == true)) {
              debugPrint('WebView error: ${error.description}');
              // If it's a payment response URL, hide WebView and verify
              final uri = Uri.tryParse(error.url ?? '');
              if (uri != null && uri.path.contains('/api/payment/response')) {
                setState(() {
                  _showWebView = false;
                });
                _confirmAndClose(callback: uri);
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _maybeVerifyByUrl(String? url) {
    if (_finished || url == null) return;
    final uri = Uri.tryParse(url);
    final u = url.toLowerCase();

    // ✅ আমাদের callback route hit হলে সরাসরি ওই URL দিয়েই verify করি
    final isCallback =
        uri != null && uri.path.contains('/api/payment/response');
    final looksSuccess = successHints.any((h) => u.contains(h));

    if (isCallback || looksSuccess) {
      _confirmAndClose(callback: uri);
    }
  }

  Future<void> _inspectDom() async {
    if (_finished || _verifying) return;
    try {
      final raw = await _c.runJavaScriptReturningResult(
        r'''(function(){const t=document.body?(document.body.innerText||document.body.textContent):'';return t;})();''',
      );
      String text = raw.toString() ?? '';
      if (text.startsWith('"') && text.endsWith('"')) {
        text = json.decode(text);
      }
      final l = text.toLowerCase();
      if (l.contains('thanks for your payment') ||
          l.contains('payment successful') ||
          l.contains('transaction was completed successfully')) {
        _confirmAndClose(); // DOM hint পেলেও verify করে নেব
      }
    } catch (_) {}
  }

  Future<void> _confirmAndClose({Uri? callback}) async {
    if (_finished || _verifying) return;
    
    setState(() {
      _verifying = true;
      _showWebView = false; // Hide WebView while verifying
    });

    final ok = await verifyPaymentFromServer(
      context,
      callbackUri: callback, // থাকলে: tx_ref/transaction_id/status নিয়ে নিবে
    );

    if (!mounted || _finished) return;

    setState(() {
      _verifying = false;
    });

    if (ok) {
      _finished = true;
      Navigator.pop(context, PaymentStatusResult(success: true));
    } else {
      // If verification fails, show WebView again
      setState(() {
        _showWebView = true;
      });
    }
    // না হলে কিছুই করবে না—gateway/সার্ভার আপডেট নিলে আবার URL/DOM চেঞ্জে ট্রিগার হবে
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: Stack(
        children: [
          // Show WebView only when not verifying and not finished
          if (_showWebView && !_verifying && !_finished)
            WebViewWidget(controller: _c),
          
          // Show loading indicator when verifying payment
          if (_verifying || (!_showWebView && !_finished))
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Loading...'),
                    SizedBox(height: 16),
                    Text(
                      'Verifying payment...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
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

// lib/features/buyer/screens/prement/screen/web_view_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:market_jango/features/buyer/screens/prement/logic/status_check_logic.dart';
import 'package:market_jango/features/buyer/screens/prement/model/prement_line_items.dart';

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

  final successHints = const ['success','complete','paid','payment/success','successful'];

  @override
  void initState() {
    super.initState();
    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (req) {
            _maybeVerifyByUrl(req.url);
            return NavigationDecision.navigate;
          },
          onUrlChange: (c) => _maybeVerifyByUrl(c.url),
          onPageFinished: (_) => _inspectDom(),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _maybeVerifyByUrl(String? url) {
    if (_finished || url == null) return;
    final uri = Uri.tryParse(url);
    final u = url.toLowerCase();

    // ✅ আমাদের callback route hit হলে সরাসরি ওই URL দিয়েই verify করি
    final isCallback = uri != null && uri.path.contains('/api/payment/response');
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
      String text = raw?.toString() ?? '';
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
    _verifying = true;

    final ok = await verifyPaymentFromServer(
      context,
      callbackUri: callback, // থাকলে: tx_ref/transaction_id/status নিয়ে নিবে
    );

    _verifying = false;
    if (!mounted || _finished) return;

    if (ok) {
      _finished = true;
      Navigator.pop(context, PaymentStatusResult(success: true));
    }
    // না হলে কিছুই করবে না—gateway/সার্ভার আপডেট নিলে আবার URL/DOM চেঞ্জে ট্রিগার হবে
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: Stack(
        children: [
          WebViewWidget(controller: _c),
          Positioned(
            left: 16, right: 16, bottom: 16,
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      await _confirmAndClose(); // ম্যানুয়াল verify
                      if (mounted && !_finished) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Not completed yet. Please wait…')),
                        );
                      }
                    },
                    child: const Text("I've paid — check status"),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    if (!_finished) Navigator.pop(context, PaymentStatusResult(success: false));
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
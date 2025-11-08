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
  Timer? _pollTimer;

  // success hint গুলো (তোমার গেটওয়ের রিটার্ন URL/টেক্সট অনুযায়ী বাড়াতে পারো)
  final List<String> successUrlHints = const [
    'success','complete','paid','payment/success','successful'
  ];

  @override
  void initState() {
    super.initState();
    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (change) => _maybeSuccessByUrl(change.url),
          onNavigationRequest: (req) {
            _maybeSuccessByUrl(req.url);
            return NavigationDecision.navigate;
          },
          onPageFinished: (_) => _ensurePolling(),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _ensurePolling() {
    _pollTimer ??= Timer.periodic(const Duration(seconds: 1), (_) => _inspectDom());
  }

  Future<void> _inspectDom() async {
    if (_finished) return;
    try {
      final raw = await _c.runJavaScriptReturningResult(r'''
        (function(){
          const t = document.body ? (document.body.innerText || document.body.textContent) : '';
          return t;
        })();
      ''');
      String text = raw?.toString() ?? '';
      if (text.startsWith('"') && text.endsWith('"')) {
        text = json.decode(text);
      }
      final l = text.toLowerCase();

      if (l.contains('thanks for your payment') ||
          l.contains('payment successful') ||
          l.contains('transaction was completed successfully')) {
        _confirmThenPop(successHint: 'dom');
      }
    } catch (_) {}
  }

  void _maybeSuccessByUrl(String? url) {
    if (_finished || url == null) return;
    final u = url.toLowerCase();
    if (successUrlHints.any((h) => u.contains(h))) {
      _confirmThenPop(successHint: 'url');
    }
  }

  /// ✅ success hint পেলেই সার্ভার verify — না হলে পেজ খোলা থাকবে
  Future<void> _confirmThenPop({required String successHint}) async {
    if (_finished) return;
    final ok = await verifyPaymentFromServer(context);
    if (!mounted || _finished) return;
    if (ok) {
      _pop(success: true, reason: 'verified-$successHint');
    } else {
      // verify না হলে কিছুই করবো না (পেজ খোলা থাকবে)
    }
  }

  void _pop({required bool success, String? reason}) {
    if (_finished || !mounted) return;
    _finished = true;
    _pollTimer?.cancel();
    Navigator.pop(context, PaymentStatusResult(success: success));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: Stack(
        children: [
          WebViewWidget(controller: _c),

          // ম্যানুয়াল: I've paid → server verify
          Positioned(
            left: 16, right: 16, bottom: 16,
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      final ok = await verifyPaymentFromServer(context);
                      if (!mounted) return;
                      if (ok) {
                        Navigator.pop(context, PaymentStatusResult(success: true));
                      } else {
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
                  onPressed: () => _pop(success: false, reason: 'user-close'),
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
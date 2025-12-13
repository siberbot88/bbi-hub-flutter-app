import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Midtrans Payment WebView
/// Opens Midtrans Snap payment page and handles callbacks
class MidtransPaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final String snapToken;

  const MidtransPaymentWebView({
    Key? key,
    required this.paymentUrl,
    required this.snapToken,
  }) : super(key: key);

  @override
  State<MidtransPaymentWebView> createState() => _MidtransPaymentWebViewState();
}

class _MidtransPaymentWebViewState extends State<MidtransPaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _checkPaymentStatus(url);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkPaymentStatus(String url) {
    // Midtrans callback URLs typically contain status
    if (url.contains('status_code=200') || 
        url.contains('transaction_status=settlement') ||
        url.contains('transaction_status=capture')) {
      // Payment successful
      Navigator.pop(context, 'success');
    } else if (url.contains('status_code=201')) {
      // Pending payment
      Navigator.pop(context, 'pending');
    } else if (url.contains('transaction_status=deny') ||
               url.contains('transaction_status=cancel') ||
               url.contains('transaction_status=expire')) {
      // Payment failed/cancelled
      Navigator.pop(context, 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Trial'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, 'cancelled'),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nawa_niwasa/ui/ui.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatelessWidget {
  final WebViewController controller;

  const WebViewPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: AppColors.red,
      ),
      body: SafeArea(
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPagerenev extends StatefulWidget {
  const WebViewPagerenev({Key? key}) : super(key: key);

  @override
  State<WebViewPagerenev> createState() => _WebViewPagerenevState();
}

class _WebViewPagerenevState extends State<WebViewPagerenev> {
  bool _isLoading = true; // Boolean to track loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text('Renew'),
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl:
            'https://muat.megainsurance.id:8081/PortalInsurance/Form/Input?pt=hcVjNbmEGEmVQk1wYVWaxA&pr=5f5YCPlrMUKgUm-Eox5tEA',
            javascriptMode: JavascriptMode.unrestricted,
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true; // Show loading indicator
              });
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false; // Hide loading indicator
              });
            },
          ),
          if (_isLoading)
            Center(
              child: LoadingAnimationWidget.newtonCradle(
                color:Colors.orange,
                size: 100,
              ), // Loading indicator
            ),
        ],
      ),
    );
  }
}

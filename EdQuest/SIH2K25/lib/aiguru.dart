import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

class AIGuruChatbot extends StatefulWidget {
  const AIGuruChatbot({super.key});

  @override
  State<AIGuruChatbot> createState() => _AIGuruChatbotState();
}

class _AIGuruChatbotState extends State<AIGuruChatbot> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            debugPrint('WebView error: $error');
          },
        ),
      );

    _loadHtmlFromAssets();
  }

  void _loadHtmlFromAssets() async {
    try {
      final String fileHtmlContents =
          await rootBundle.loadString('assets/aiguru/AIGuru.html');
      _controller.loadHtmlString(fileHtmlContents);
    } catch (e) {
      debugPrint('Failed to load asset: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 400, // fixed height for home page
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class UnityGamePage extends StatefulWidget {
  const UnityGamePage({super.key});

  @override
  State<UnityGamePage> createState() => _UnityGamePageState();
}

class _UnityGamePageState extends State<UnityGamePage> {
  final String gameUrl = "https://kidmonrevamp.vercel.app/";
  InAppWebViewController? _controller;
  bool _isLoading = true;
  bool _loadFailed = false;
  String _errorMessage = "";
  Timer? _resizeTimer;

  @override
  void initState() {
    super.initState();
    // Lock to landscape and enter immersive full-screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _resizeTimer?.cancel();
    // Restore portrait and system UI on exit
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(gameUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open browser')),
        );
      }
    }
  }

  Future<void> _reload() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
      _errorMessage = "";
    });

    try {
      await _controller?.reload();
      _scheduleResizeInjection(retries: 4);
    } catch (e) {
      try {
        await _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(gameUrl)));
        _scheduleResizeInjection(retries: 4);
      } catch (e2) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _loadFailed = true;
            _errorMessage = "Reload failed: $e2";
          });
        }
      }
    }
  }

  // JS to force canvas and container to fill available space
  static const String _forceResizeJs = r'''
(function(){
  try{
    document.documentElement.style.height = '100%';
    document.body.style.height = '100%';
    document.body.style.margin = '0';
    var container = document.getElementById('unity-container') || document.getElementById('unityParent') || document.body;
    if(container){
      container.style.width = '100%';
      container.style.height = '100%';
      container.style.position = 'absolute';
      container.style.top = '0';
      container.style.left = '0';
    }
    var canvas = document.getElementById('unity-canvas') || document.querySelector('canvas');
    if(canvas){
      canvas.style.width = '100%';
      canvas.style.height = '100%';
      canvas.style.position = 'absolute';
      canvas.style.top = '0';
      canvas.style.left = '0';
      try {
        canvas.width = Math.floor(window.innerWidth * (window.devicePixelRatio || 1));
        canvas.height = Math.floor(window.innerHeight * (window.devicePixelRatio || 1));
      } catch(e) {}
      console.log('UnityCanvasResized', canvas.width || 0, canvas.height || 0);
    } else {
      console.log('NoUnityCanvasFound');
    }
  } catch(e) {
    console.log('ForceResizeError', e.toString());
  }
})();
''';

  // run the resize injection multiple times
  void _scheduleResizeInjection({int retries = 3, Duration gap = const Duration(milliseconds: 350)}) {
    int attempts = 0;
    _resizeTimer?.cancel();
    _resizeTimer = Timer.periodic(gap, (t) async {
      attempts++;
      try {
        await _controller?.evaluateJavascript(source: _forceResizeJs);
      } catch (_) {}
      if (attempts >= retries) {
        t.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The WebView now fills the entire screen without any padding
          Positioned.fill(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(gameUrl)),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  transparentBackground: false,
                  useOnLoadResource: true,
                  mediaPlaybackRequiresUserGesture: false,
                  allowUniversalAccessFromFileURLs: true,
                  userAgent:
                      'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
                ),
                android: AndroidInAppWebViewOptions(
                  useHybridComposition: true,
                  mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                  useWideViewPort: true,
                  builtInZoomControls: false,
                  displayZoomControls: false,
                ),
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
              },
              onLoadStart: (controller, url) {
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                    _loadFailed = false;
                  });
                }
              },
              onLoadStop: (controller, url) async {
                _scheduleResizeInjection(retries: 6, gap: const Duration(milliseconds: 300));
                try {
                  await controller.evaluateJavascript(source: "console.log('PageLoadComplete');");
                } catch (_) {}
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _loadFailed = false;
                  });
                }
              },
              onLoadError: (controller, url, code, message) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _loadFailed = true;
                    _errorMessage = "Code $code - $message";
                  });
                }
              },
              onConsoleMessage: (controller, consoleMessage) {
                debugPrint('UnityLog: ${consoleMessage.message}');
              },
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),

          // Error overlay
          if (_loadFailed)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 56, color: Colors.white),
                    const SizedBox(height: 12),
                    const Text(
                      "Web page not available",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _reload,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _openInBrowser,
                          icon: const Icon(Icons.open_in_browser),
                          label: const Text("Open in Browser"),
                        ),
                      ],
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
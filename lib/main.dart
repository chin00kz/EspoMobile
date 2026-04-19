import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ESM Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const WebsiteScreen(),
    );
  }
}

class WebsiteScreen extends StatefulWidget {
  const WebsiteScreen({super.key});

  @override
  State<WebsiteScreen> createState() => _WebsiteScreenState();
}

class _WebsiteScreenState extends State<WebsiteScreen> {
  static const String _url = 'https://www.fedex.esm.lk/';

  InAppWebViewController? _webViewController;
  late final PullToRefreshController _pullToRefreshController;
  bool _isLoading = true;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.indigo,
        backgroundColor: Colors.white,
      ),
      onRefresh: () async {
        await _webViewController?.reload();
      },
    );
  }

  Future<void> _handleBackPressed() async {
    if (_webViewController != null && await _webViewController!.canGoBack()) {
      await _webViewController!.goBack();
      return;
    }

    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          await _handleBackPressed();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(_url)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  transparentBackground: false,
                ),
                pullToRefreshController: _pullToRefreshController,
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _isLoading = true;
                  });
                },
                onProgressChanged: (controller, progress) {
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _progress = progress;
                    if (progress >= 100) {
                      _isLoading = false;
                    }
                  });
                },
                onLoadStop: (controller, url) async {
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _isLoading = false;
                  });
                  await _pullToRefreshController.endRefreshing();
                },
                onReceivedError: (controller, request, error) async {
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _isLoading = false;
                  });
                  await _pullToRefreshController.endRefreshing();
                },
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              if (_isLoading)
                Align(
                  alignment: Alignment.topCenter,
                  child: LinearProgressIndicator(
                    value: _progress == 0 ? null : _progress / 100,
                  ),
                ),
              Positioned(
                bottom: 16,
                right: 8,
                child: Opacity(
                  opacity: 0.45,
                  child: Material(
                    color: Colors.transparent,
                    child: Ink(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: InkWell(
                        onTap: _handleBackPressed,
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
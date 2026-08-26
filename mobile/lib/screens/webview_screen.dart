import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../widgets/exit_confirmation_dialog.dart';
import '../widgets/server_config_dialog.dart';
import '../widgets/offline_widget.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  static const String _defaultUrl = 'https://kitchen-os-seven.vercel.app/';
  static const String _urlKey = 'kitchenos_target_url';

  late final WebViewController _controller;
  String _currentUrl = _defaultUrl;
  int _loadingProgress = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
    _loadSavedUrl();
  }

  void _initWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFDFBF7))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
              _isLoading = progress < 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
              _errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // Filter main page load errors vs minor subresource missing errors
            if (error.isForMainFrame ?? true) {
              setState(() {
                _hasError = true;
                _isLoading = false;
                _errorMessage = error.description;
              });
            }
          },
        ),
      );
  }

  Future<void> _loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(_urlKey) ?? _defaultUrl;
    setState(() {
      _currentUrl = savedUrl;
    });
    _controller.loadRequest(Uri.parse(_currentUrl));
  }

  Future<void> _updateTargetUrl(String newUrl) async {
    if (newUrl.trim().isEmpty) return;

    var formattedUrl = newUrl.trim();
    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlKey, formattedUrl);

    setState(() {
      _currentUrl = formattedUrl;
      _hasError = false;
      _isLoading = true;
    });

    _controller.loadRequest(Uri.parse(_currentUrl));
  }

  Future<void> _reloadPage() async {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    _controller.reload();
  }

  Future<void> _handlePopScope(bool didPop, dynamic result) async {
    if (didPop) return;

    // Check if WebView can navigate back in browser history
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else {
      // On root page: show custom exit confirmation dialog
      if (!mounted) return;
      final shouldExit = await ExitConfirmationDialog.show(context);
      if (shouldExit && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handlePopScope,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFBF7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFDFBF7),
          elevation: 0,
          scrolledUnderElevation: 1,
          surfaceTintColor: const Color(0xFFFDFBF7),
          titleSpacing: 16,
          title: Row(
            children: [
              // Official KitchenOS ChefHat Emblem Box
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF292524),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.soup_kitchen_rounded,
                  color: Color(0xFFF5F5F4),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KitchenOS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1917),
                      letterSpacing: -0.4,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _hasError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _hasError ? 'Offline' : 'Connected',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _hasError ? const Color(0xFFEF4444) : const Color(0xFF78716C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // Server URL Switcher Button
            IconButton(
              tooltip: 'Server Settings',
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E5E4).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.dns_rounded,
                  color: Color(0xFF292524),
                  size: 20,
                ),
              ),
              onPressed: () async {
                final newUrl = await ServerConfigDialog.show(context, _currentUrl);
                if (newUrl != null && newUrl != _currentUrl) {
                  _updateTargetUrl(newUrl);
                }
              },
            ),
            // Reload Button
            IconButton(
              tooltip: 'Reload Page',
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E5E4).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF292524),
                  size: 20,
                ),
              ),
              onPressed: _reloadPage,
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: _isLoading
                ? LinearProgressIndicator(
                    value: _loadingProgress / 100.0,
                    backgroundColor: const Color(0xFFE7E5E4),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF292524)),
                    minHeight: 2.5,
                  )
                : const SizedBox(height: 2.5),
          ),
        ),
        body: SafeArea(
          child: _hasError
              ? OfflineWidget(
                  errorMessage: _errorMessage,
                  onRetry: _reloadPage,
                )
              : RefreshIndicator(
                  color: const Color(0xFF292524),
                  backgroundColor: const Color(0xFFFFFFFF),
                  onRefresh: _reloadPage,
                  child: WebViewWidget(controller: _controller),
                ),
        ),
      ),
    );
  }
}

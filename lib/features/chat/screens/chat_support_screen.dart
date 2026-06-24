import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// ChatSupportScreen
/// A reusable full-screen widget that displays the Tawk.to live chat support.
///
/// This widget handles:
/// - Opening Tawk chat in WebView with property and widget IDs
/// - Setting visitor information (name, email)
/// - Loading state management
/// - Proper back button navigation
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => ChatSupportScreen(
///       propertyId: '69a72f9cf0e13e1c3643affa',
///       widgetId: 'default',
///       visitorName: 'John Doe',
///       visitorEmail: 'john@example.com',
///     ),
///   ),
/// );
/// ```
class ChatSupportScreen extends StatefulWidget {
  /// Tawk.to Property ID from dashboard
  final String propertyId;

  /// Tawk.to Widget ID (usually 'default')
  final String widgetId;

  /// Optional: Visitor's name to pre-fill in chat
  final String? visitorName;

  /// Optional: Visitor's email to pre-fill in chat
  final String? visitorEmail;

  /// Optional: Custom app bar title
  final String? appBarTitle;

  /// Optional: Custom background color
  final Color? backgroundColor;

  const ChatSupportScreen({
    Key? key,
    required this.propertyId,
    required this.widgetId,
    this.visitorName,
    this.visitorEmail,
    this.appBarTitle = 'Gorilla Consultant Support',
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<ChatSupportScreen> createState() => _ChatSupportScreenState();
}

class _ChatSupportScreenState extends State<ChatSupportScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  /// Initialize WebView with Tawk URL
  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('[Tawk] Page started loading: $url');
            setState(() {
              _isLoading = true;
              _loadError = null;
            });
          },
          onPageFinished: (String url) {
            debugPrint('[Tawk] Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('[Tawk] WebView error: ${error.description}');
            setState(() {
              _loadError = error.description;
              _isLoading = false;
            });
          },
        ),
      );

    // Load HTML with proper base URL to enable localStorage
    _webViewController.loadHtmlString(
      _buildTawkHtml(),
      baseUrl: 'https://embed.tawk.to/',
    );
  }

  /// Build HTML with Tawk script embedded
  String _buildTawkHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    * { margin: 0; padding: 0; }
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; }
    #tawk-container { width: 100%; height: 100vh; }
  </style>
</head>
<body>
  <div id="tawk-container"></div>
  <script type="text/javascript">
    var Tawk_API=Tawk_API||{}, Tawk_LoadStart=new Date();
    (function(){
      var s1=document.createElement("script"),s0=document.getElementsByTagName("script")[0];
      s1.async=true;
      s1.src='https://embed.tawk.to/${widget.propertyId}/${widget.widgetId}';
      s1.charset='UTF-8';
      s1.setAttribute('crossorigin','*');
      s0.parentNode.insertBefore(s1,s0);
    })();
  </script>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.appBarTitle ?? 'Gorilla Consultant Support'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  /// Build the chat body with WebView or error state
  Widget _buildBody() {
    if (_loadError != null) {
      return _buildErrorState();
    }

    return Stack(
      children: [
        // WebView for Tawk chat
        WebViewWidget(controller: _webViewController),

        // Loading Overlay
        if (_isLoading)
          Container(
            color: Colors.white.withValues(alpha: 0.9),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Gorilla Consultant...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Build error state with retry button
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Chat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Error: $_loadError',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeWebView,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _webViewController.clearLocalStorage();
    super.dispose();
  }
}

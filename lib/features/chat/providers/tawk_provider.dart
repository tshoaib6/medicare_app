import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// TawkProvider
/// Provider for managing Tawk chat state and configuration across the app
///
/// This provider handles:
/// - Storing Tawk credentials (propertyId, widgetId)
/// - Managing chat visibility state
/// - Storing visitor information
/// - Launching Tawk chat interface
class TawkProvider with ChangeNotifier {
  // Tawk Configuration
  static const String defaultPropertyId = '69a72f9cf0e13e1c3643affa';
  static const String defaultWidgetId = '1jiqh3vg3';

  // State variables
  String _propertyId = defaultPropertyId;
  String _widgetId = defaultWidgetId;
  String? _visitorName;
  String? _visitorEmail;
  bool _isChatOpen = false;

  // Getters
  String get propertyId => _propertyId;
  String get widgetId => _widgetId;
  String? get visitorName => _visitorName;
  String? get visitorEmail => _visitorEmail;
  bool get isChatOpen => _isChatOpen;

  /// Initialize Tawk with custom credentials
  void initializeTawk({
    String? propertyId,
    String? widgetId,
    String? visitorName,
    String? visitorEmail,
  }) {
    if (propertyId != null) _propertyId = propertyId;
    if (widgetId != null) _widgetId = widgetId;
    if (visitorName != null) _visitorName = visitorName;
    if (visitorEmail != null) _visitorEmail = visitorEmail;

    debugPrint(
        '[Tawk] Initialized with Property: $_propertyId, Widget: $_widgetId');
    notifyListeners();
  }

  /// Set visitor information
  void setVisitorInfo({
    String? visitorName,
    String? visitorEmail,
  }) {
    if (visitorName != null) _visitorName = visitorName;
    if (visitorEmail != null) _visitorEmail = visitorEmail;

    debugPrint(
        '[Tawk] Visitor info set - Name: $_visitorName, Email: $_visitorEmail');
    notifyListeners();
  }

  /// Open/Maximize chat
  Future<void> maximizeChat() async {
    try {
      _isChatOpen = true;
      notifyListeners();

      // Build Tawk URL with visitor info using embed domain
      String url = 'https://embed.tawk.to/$_propertyId/$_widgetId';

      if (_visitorName != null && _visitorName!.isNotEmpty) {
        url += '?name=${Uri.encodeComponent(_visitorName!)}';
      }

      if (_visitorEmail != null && _visitorEmail!.isNotEmpty) {
        final separator = _visitorName != null ? '&' : '?';
        url += '$separator email=${Uri.encodeComponent(_visitorEmail!)}';
      }

      debugPrint('[Tawk] Opening chat: $url');

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        debugPrint('[Tawk] Could not launch Tawk URL');
      }
    } catch (e) {
      debugPrint('[Tawk] Error opening chat: $e');
    }
  }

  /// Close/Minimize chat
  void minimizeChat() {
    _isChatOpen = false;
    debugPrint('[Tawk] Chat minimized');
    notifyListeners();
  }

  /// Toggle chat visibility
  Future<void> toggleChat() async {
    if (_isChatOpen) {
      minimizeChat();
    } else {
      await maximizeChat();
    }
  }

  /// Clear all stored data
  void reset() {
    _propertyId = defaultPropertyId;
    _widgetId = defaultWidgetId;
    _visitorName = null;
    _visitorEmail = null;
    _isChatOpen = false;

    debugPrint('[Tawk] Provider reset');
    notifyListeners();
  }
}

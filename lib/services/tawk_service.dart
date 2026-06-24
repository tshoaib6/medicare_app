import 'package:flutter/foundation.dart';

/// TawkService
/// Service layer for Tawk.to live chat integration
///
/// This service handles:
/// - Configuration management
/// - Visitor information
/// - Chat state tracking
class TawkService {
  static final TawkService _instance = TawkService._internal();

  factory TawkService() {
    return _instance;
  }

  TawkService._internal();

  // Tawk Configuration - Update these with your actual credentials
  // Get from: https://dashboard.tawk.to/ → Settings → Widget
  static const String defaultPropertyId = '69a72f9cf0e13e1c3643affa';
  static const String defaultWidgetId = 'default';

  // Private variables
  Map<String, String> _visitorInfo = {};
  String _currentPropertyId = defaultPropertyId;
  String _currentWidgetId = defaultWidgetId;

  // Getters
  String get propertyId => _currentPropertyId;
  String get widgetId => _currentWidgetId;
  Map<String, String> get visitorInfo => Map.unmodifiable(_visitorInfo);

  /// Initialize Tawk with custom credentials
  void initialize({
    required String propertyId,
    String widgetId = 'default',
  }) {
    _currentPropertyId = propertyId;
    _currentWidgetId = widgetId;

    debugPrint(
      '[Tawk] Initialized - PropertyId: $propertyId, WidgetId: $widgetId',
    );
  }

  /// Set visitor information
  void setVisitorInfo({
    String? name,
    String? email,
    Map<String, dynamic>? attributes,
  }) {
    _visitorInfo.clear();

    if (name != null && name.isNotEmpty) {
      _visitorInfo['name'] = name;
    }
    if (email != null && email.isNotEmpty) {
      _visitorInfo['email'] = email;
    }

    if (attributes != null) {
      attributes.forEach((key, value) {
        _visitorInfo[key] = value.toString();
      });
    }

    debugPrint('[Tawk] Visitor info set: $_visitorInfo');
  }

  /// Clear visitor information
  void clearVisitorInfo() {
    _visitorInfo.clear();
    debugPrint('[Tawk] Visitor info cleared');
  }

  /// Update specific attribute
  void updateAttribute(String key, dynamic value) {
    _visitorInfo[key] = value.toString();
    debugPrint('[Tawk] Attribute updated - $key: ${value.toString()}');
  }

  /// Reset to defaults
  void reset() {
    _currentPropertyId = defaultPropertyId;
    _currentWidgetId = defaultWidgetId;
    _visitorInfo.clear();

    debugPrint('[Tawk] Service reset to defaults');
  }
}

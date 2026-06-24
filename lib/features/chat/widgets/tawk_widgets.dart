import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tawk_provider.dart';
import '../screens/chat_support_screen.dart';

/// TawkChatFAB
/// Floating Action Button to open Tawk live chat support.
///
/// This FAB:
/// - Shows a chat icon
/// - Opens ChatSupportScreen on tap
/// - Can be customized with colors
/// - Displays a tooltip on long press
///
/// Usage:
/// ```dart
/// floatingActionButton: TawkChatFAB(
///   visitorName: 'John Doe',
///   visitorEmail: 'john@example.com',
/// ),
/// ```
class TawkChatFAB extends StatelessWidget {
  /// Optional: Visitor name to pre-fill
  final String? visitorName;

  /// Optional: Visitor email to pre-fill
  final String? visitorEmail;

  /// Optional: Custom background color
  final Color? backgroundColor;

  /// Optional: Custom icon color
  final Color? iconColor;

  /// Optional: Custom Tawk property ID
  final String? propertyId;

  /// Optional: Custom Tawk widget ID
  final String? widgetId;

  const TawkChatFAB({
    Key? key,
    this.visitorName,
    this.visitorEmail,
    this.backgroundColor,
    this.iconColor,
    this.propertyId,
    this.widgetId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _openChatSupport(context),
      tooltip: 'Chat with Gorilla Consultant',
      backgroundColor: backgroundColor ?? Colors.blue.shade600,
      child: Icon(
        Icons.chat_bubble,
        color: iconColor ?? Colors.white,
      ),
    );
  }

  /// Open the chat support screen
  void _openChatSupport(BuildContext context) {
    final tawkProvider = context.read<TawkProvider>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatSupportScreen(
          propertyId: propertyId ?? tawkProvider.propertyId,
          widgetId: widgetId ?? tawkProvider.widgetId,
          visitorName: visitorName,
          visitorEmail: visitorEmail,
        ),
      ),
    );
  }
}

/// TawkChatButton
/// Regular button to open Tawk live chat.
///
/// Features:
/// - Customizable label
/// - Icon support
/// - Button styling options
class TawkChatButton extends StatelessWidget {
  /// Button label text
  final String label;

  /// Optional: Visitor name
  final String? visitorName;

  /// Optional: Visitor email
  final String? visitorEmail;

  /// Optional: Custom background color
  final Color? backgroundColor;

  /// Optional: Custom text color
  final Color? textColor;

  /// Optional: Custom icon
  final IconData? icon;

  const TawkChatButton({
    Key? key,
    this.label = 'Chat with Support',
    this.visitorName,
    this.visitorEmail,
    this.backgroundColor,
    this.textColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _openChatSupport(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.blue.shade600,
        foregroundColor: textColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(icon ?? Icons.chat),
      label: Text(label),
    );
  }

  /// Open the chat support screen
  void _openChatSupport(BuildContext context) {
    final tawkProvider = context.read<TawkProvider>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatSupportScreen(
          propertyId: tawkProvider.propertyId,
          widgetId: tawkProvider.widgetId,
          visitorName: visitorName,
          visitorEmail: visitorEmail,
        ),
      ),
    );
  }
}

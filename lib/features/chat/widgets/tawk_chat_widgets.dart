import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tawk_provider.dart';
import '../screens/chat_support_screen.dart';

/// Floating Action Button for Gorilla Consultant Chat
class TawkChatFab extends StatelessWidget {
  final String? visitorName;
  final String? visitorEmail;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const TawkChatFab({
    super.key,
    this.visitorName,
    this.visitorEmail,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TawkProvider>(
      builder: (context, tawkProvider, _) {
        return FloatingActionButton(
          backgroundColor: backgroundColor ?? Colors.blue.shade600,
          foregroundColor: foregroundColor ?? Colors.white,
          tooltip: 'Gorilla Consultant Chat',
          onPressed: () {
            // Update visitor info if provided
            if (visitorName != null || visitorEmail != null) {
              tawkProvider.setVisitorInfo(
                visitorName: visitorName,
                visitorEmail: visitorEmail,
              );
            }

            // Navigate to chat screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatSupportScreen(
                  propertyId: tawkProvider.propertyId,
                  widgetId: tawkProvider.widgetId,
                  visitorName: visitorName ?? tawkProvider.visitorName,
                  visitorEmail: visitorEmail ?? tawkProvider.visitorEmail,
                ),
              ),
            );
          },
          child: const Icon(Icons.chat_bubble),
        );
      },
    );
  }
}

/// Action button for AppBar
class TawkChatAction extends StatelessWidget {
  final String? visitorName;
  final String? visitorEmail;

  const TawkChatAction({
    super.key,
    this.visitorName,
    this.visitorEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TawkProvider>(
      builder: (context, tawkProvider, _) {
        return IconButton(
          icon: const Icon(Icons.chat_bubble_outline),
          tooltip: 'Chat with Gorilla Consultant',
          onPressed: () {
            // Update visitor info if provided
            if (visitorName != null || visitorEmail != null) {
              tawkProvider.setVisitorInfo(
                visitorName: visitorName,
                visitorEmail: visitorEmail,
              );
            }

            // Navigate to chat screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatSupportScreen(
                  propertyId: tawkProvider.propertyId,
                  widgetId: tawkProvider.widgetId,
                  visitorName: visitorName ?? tawkProvider.visitorName,
                  visitorEmail: visitorEmail ?? tawkProvider.visitorEmail,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Custom Chat Button Widget
class TawkChatButton extends StatelessWidget {
  final String label;
  final String? visitorName;
  final String? visitorEmail;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const TawkChatButton({
    super.key,
    this.label = 'Chat with Gorilla Consultant',
    this.visitorName,
    this.visitorEmail,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TawkProvider>(
      builder: (context, tawkProvider, _) {
        return ElevatedButton.icon(
          onPressed: () {
            // Update visitor info if provided
            if (visitorName != null || visitorEmail != null) {
              tawkProvider.setVisitorInfo(
                visitorName: visitorName,
                visitorEmail: visitorEmail,
              );
            }

            // Navigate to chat screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatSupportScreen(
                  propertyId: tawkProvider.propertyId,
                  widgetId: tawkProvider.widgetId,
                  visitorName: visitorName ?? tawkProvider.visitorName,
                  visitorEmail: visitorEmail ?? tawkProvider.visitorEmail,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.blue.shade600,
            foregroundColor: textColor ?? Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(icon ?? Icons.chat),
          label: Text(label),
        );
      },
    );
  }
}

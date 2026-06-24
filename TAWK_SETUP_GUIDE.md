# Gorilla Consultant - Tawk.to Live Chat Integration

Complete integration of Tawk.to live chat support into your Flutter app.

## 📋 Requirements

- ✅ `flutter_tawk_to_plus` package (v1.2.0+)
- ✅ Android & iOS support
- ✅ Reusable `ChatSupportScreen` widget
- ✅ Floating Action Button for easy access
- ✅ Visitor information pre-filling
- ✅ Loading indicator
- ✅ Proper back navigation
- ✅ Clean code structure
- ✅ Null-safety enabled
- ✅ Comprehensive comments

## 🚀 Quick Start

### 1. Get Your Tawk Credentials

1. Visit [Tawk.to Dashboard](https://dashboard.tawk.to/)
2. Go to **Settings** → **Property** → **API & Webhooks**
3. Copy your **Property ID**
4. Your Widget ID is typically `default` (or custom if you created one)

### 2. Update Configuration

Open `lib/services/tawk_service.dart` and update:

```dart
static const String defaultPropertyId = 'YOUR_PROPERTY_ID';
static const String defaultWidgetId = 'default';
```

**Example:**
```dart
static const String defaultPropertyId = '61c6c5f5d1fd2a0018d3e4a2';
static const String defaultWidgetId = 'default';
```

## 📁 Project Structure

```
lib/
├── main.dart                           # App entry point with providers
├── services/
│   └── tawk_service.dart              # Tawk service layer
├── features/
│   └── chat/
│       ├── providers/
│       │   └── tawk_provider.dart     # State management
│       ├── screens/
│       │   └── chat_support_screen.dart # Full-screen chat widget
│       └── widgets/
│           └── tawk_widgets.dart       # FAB and button components
└── pubspec.yaml                        # Dependencies
```

## 📦 Dependencies Added

```yaml
dependencies:
  flutter_tawk_to_plus: ^1.2.0  # Tawk live chat
```

Install with:
```bash
flutter pub get
```

## 💻 Code Usage Examples

### Using the Floating Action Button (Dashboard)

The FAB is automatically added to the Dashboard screen:

```dart
floatingActionButton: TawkChatFAB(
  visitorName: 'John Doe',
  visitorEmail: 'john@example.com',
),
```

### Opening Chat Programmatically

```dart
// From any screen with provider access:
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => ChatSupportScreen(
      propertyId: 'YOUR_PROPERTY_ID',
      widgetId: 'default',
      visitorName: 'John Doe',
      visitorEmail: 'john@example.com',
    ),
  ),
);
```

### Using the Chat Button

```dart
TawkChatButton(
  label: 'Chat with Support',
  visitorName: 'John Doe',
  visitorEmail: 'john@example.com',
)
```

### Setting Visitor Information

```dart
final tawkProvider = context.read<TawkProvider>();

tawkProvider.setVisitorInfo(
  visitorName: 'Jane Smith',
  visitorEmail: 'jane@example.com',
);
```

## 🔧 Customization

### Custom Colors

```dart
TawkChatFAB(
  backgroundColor: Colors.purple.shade600,
  iconColor: Colors.white,
  visitorName: 'User Name',
  visitorEmail: 'user@example.com',
)
```

### Custom Properties

```dart
ChatSupportScreen(
  propertyId: 'CUSTOM_PROPERTY_ID',
  widgetId: 'custom_widget',
  appBarTitle: 'Contact Support',
  backgroundColor: Color(0xFFF8FAFC),
)
```

## 🎯 Key Features

### ChatSupportScreen
- **Full-screen chat interface**
- **Loading indicator** while chat loads
- **Back button** for proper navigation
- **Pre-fill visitor information**
- **Customizable appearance**

### TawkChatFAB
- **Floating action button**
- **Automatic user detection**
- **Custom styling**
- **Easy navigation**

### TawkChatButton
- **Regular button style**
- **Icon support**
- **Custom labels**
- **Flexible placement**

### TawkProvider
- **State management**
- **Configuration storage**
- **Visitor tracking**
- **Chat state control**

## 📱 Android Setup

No additional setup required. The `flutter_tawk_to_plus` package handles Android automatically.

**Minimum Android SDK**: API 21 (5.0)

## 🍎 iOS Setup

No additional setup required. The `flutter_tawk_to_plus` package handles iOS automatically.

**Minimum iOS**: 11.0

## 🔗 File References

### main.dart
- Initializes `TawkProvider`
- Sets up app title as 'Gorilla Consultant'
- Includes all providers in `MultiProvider`

### dashboard_screen.dart
- Adds `TawkChatFAB` as floating action button
- Auto-detects user name and email
- Provides seamless chat access

### chat_support_screen.dart
- Full-screen chat widget
- Handles Tawk initialization
- Manages loading state
- Supports custom branding

### tawk_provider.dart
- Manages chat state
- Stores configuration
- Handles visitor information
- Provides convenient getters

### tawk_widgets.dart
- `TawkChatFAB`: Floating action button
- `TawkChatButton`: Regular button component

### tawk_service.dart
- Low-level service
- Configuration management
- Visitor data storage

## 🐛 Troubleshooting

### Chat doesn't appear
1. Verify Property ID and Widget ID are correct
2. Check if chat is enabled in Tawk dashboard
3. Ensure internet connectivity
4. Check Flutter console logs for errors

### Visitor info not pre-filled
1. User name/email must not be empty
2. Check `ChatSupportScreen` constructor parameters
3. Verify data before passing to widget

### Back button not working
1. Ensure using `Navigator.pop(context)`
2. Check that screen is properly pushed with `MaterialPageRoute`

### App crashes on chat open
1. Verify flutter_tawk_to_plus is installed
2. Run `flutter clean && flutter pub get`
3. Check minimum SDK versions

## 📖 Additional Resources

- [Tawk.to Official Docs](https://docs.tawk.to/)
- [flutter_tawk_to_plus Pub.dev](https://pub.dev/packages/flutter_tawk_to_plus)
- [Tawk.to Dashboard](https://dashboard.tawk.to/)

## 🤝 Support

For issues with:
- **Tawk integration**: Check [Tawk support](https://support.tawk.to/)
- **Flutter package**: Check [pub.dev discussion](https://pub.dev/packages/flutter_tawk_to_plus)
- **Your app**: Check Flutter logs with `flutter logs`

---

**App Name**: Gorilla Consultant  
**Chat Type**: Medicare Assistant  
**Status**: ✅ Ready for Production

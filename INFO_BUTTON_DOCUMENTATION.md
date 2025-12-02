# Info Button Widget Documentation

The `InfoButtonWidget` is a reusable component that can be easily added to any screen in the Medicare+ app to provide contextual information and help to users.

## Features

- **Contextual Information**: Automatically detects the current screen and shows relevant information
- **Customizable Content**: Can override title, description, and tips for specific use cases
- **Flexible Positioning**: Can be used in app bars or positioned anywhere on screen
- **Consistent Design**: Follows the app's design system with proper theming
- **Smart Tips**: Provides helpful tips specific to each screen type

## Usage Examples

### 1. In App Bar (Header)
For screens with an AppBar, use the `InfoAppBarAction` widget:

```dart
AppBar(
  title: Text('Screen Title'),
  actions: [
    InfoAppBarAction(), // Adds info button to app bar
  ],
)
```

### 2. Positioned on Screen
For screens without an AppBar or custom positioning:

```dart
Stack(
  children: [
    // Your main content
    YourMainWidget(),
    
    // Info button positioned at top right
    InfoButtonWidget(
      position: EdgeInsets.only(top: 16, right: 16),
    ),
  ],
)
```

### 3. Custom Content
Override default content for specific use cases:

```dart
InfoButtonWidget(
  title: "Custom Help Title",
  description: "Your custom description here...",
  tips: [
    "Custom tip 1",
    "Custom tip 2", 
    "Custom tip 3",
  ],
  position: EdgeInsets.only(top: 20, right: 20),
)
```

## Currently Implemented Screens

✅ **Dashboard Screen** - Floating info button with dashboard-specific help
✅ **Questionnaire Screen** - App bar info button with questionnaire guidance  
✅ **Company List Screen** - App bar info button with company browsing tips
✅ **Profile Screen** - Positioned info button with profile management help

## Screen-Specific Content

The widget automatically provides relevant content based on the current screen:

- **Dashboard**: Plan browsing, enrollment deadlines, quick actions
- **Questionnaire**: Answering tips, progress saving, accuracy importance
- **Companies**: Provider comparison, ratings, contact information
- **Profile**: Account management, privacy settings, information updates
- **Login**: Account access, password recovery, security tips

## Implementation Status

- ✅ **Core Widget Created**: `InfoButtonWidget` and `InfoAppBarAction`
- ✅ **Dashboard Integration**: Replaced existing info modal with reusable widget
- ✅ **Questionnaire Integration**: Added to questionnaire screen header
- ✅ **Company List Integration**: Added to company browsing screen
- ✅ **Profile Integration**: Added to profile management screen
- ⏳ **Additional Screens**: Can be easily added to any other screen as needed

## Benefits

1. **Consistency**: Same information pattern across all screens
2. **User Experience**: Contextual help reduces user confusion
3. **Maintainability**: Single component to update for design changes
4. **Accessibility**: Proper tooltip and screen reader support
5. **Flexibility**: Easy to customize or extend for new requirements

## Adding to New Screens

To add the info button to a new screen:

1. Import the widget:
   ```dart
   import '../../../core/widgets/info_button_widget.dart';
   ```

2. For screens with AppBar:
   ```dart
   actions: [InfoAppBarAction()],
   ```

3. For screens without AppBar:
   ```dart
   Stack(
     children: [
       // Your content...
       InfoButtonWidget(
         position: EdgeInsets.only(top: 16, right: 16),
       ),
     ],
   )
   ```

The widget will automatically detect the screen route and show appropriate content!
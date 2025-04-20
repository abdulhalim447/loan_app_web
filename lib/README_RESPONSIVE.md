# Responsive UI Implementation Guide

This guide explains how to use the responsive UI components in the World Bank Loan app to ensure a consistent web experience with fixed width on desktop platforms.

## Overview

The app uses a responsive approach that constrains all screens to a maximum width of 500px on desktop platforms (including web). This creates a mobile-like experience on larger screens, which is optimal for this application.

## How to Use the Responsive Components

### 1. Using `ResponsiveScreen` with Extension Method

The easiest way to make any screen responsive is to use the extension method at the end of your build method:

```dart
@override
Widget build(BuildContext context) {
  // Your screen content
  final content = Column(
    children: [
      // Your widgets here
    ],
  );
  
  // Return using the extension method
  return content.asResponsiveScreen(
    appBar: AppBar(title: Text('My Screen')),
    backgroundColor: AppTheme.backgroundLight,
    // Add any other Scaffold properties you need
  );
}
```

### 2. Refactoring Existing Screens

When refactoring an existing screen:

1. Split your build method into content and appBar (and any other Scaffold properties)
2. Use the extension method to wrap the content

Example:

```dart
@override
Widget build(BuildContext context) {
  // Extract the content
  final screenContent = ListView(
    children: [
      // Your existing widgets
    ],
  );
  
  // Extract the AppBar
  final appBar = AppBar(
    title: Text('Screen Title'),
    actions: [
      // Your actions
    ],
  );
  
  // Use the responsive wrapper
  return screenContent.asResponsiveScreen(
    appBar: appBar,
    bottomNavigationBar: yourBottomNav,
    floatingActionButton: yourFAB,
  );
}
```

### 3. ResponsiveScreen Properties

The `asResponsiveScreen` extension supports all standard Scaffold properties:

- `appBar`
- `bottomNavigationBar`
- `floatingActionButton`
- `floatingActionButtonLocation`
- `backgroundColor`
- `extendBody`
- `extendBodyBehindAppBar`
- `persistentFooterButtons`

## How It Works

The `ResponsiveScreen` widget:

1. Detects if the app is running on a desktop platform (web, Windows, macOS, Linux)
2. If on desktop, wraps content in a centered container with 500px max width
3. If on mobile, passes the content directly to a standard Scaffold

## Implementation in New Screens

When creating new screens:

1. Import the responsive wrapper:
   ```dart
   import 'package:world_bank_loan/core/widgets/responsive_screen.dart';
   ```

2. Structure your widget to separate content from Scaffold properties

3. Use the extension method to return the responsive version of your screen

## Notes

- All screens automatically use this approach when navigating with standard routes
- For modal dialogs or custom navigation, make sure to use the `.asResponsiveScreen()` extension 
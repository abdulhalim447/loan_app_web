import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:world_bank_loan/core/theme/app_theme.dart';
import 'dart:io' as io;

/// Base class for all screens to ensure proper responsive behavior
/// Automatically applies width constraints on desktop platforms
class ResponsiveScreen extends StatelessWidget {
  final Widget child;
  final AppBar? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final List<Widget>? persistentFooterButtons;

  const ResponsiveScreen({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.persistentFooterButtons,
  });

  // Check if the app is running on a desktop platform (web or desktop)
  bool get _isDesktop {
    if (kIsWeb) return true;
    if (!kIsWeb) {
      try {
        return io.Platform.isWindows ||
            io.Platform.isMacOS ||
            io.Platform.isLinux;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Base scaffold that will contain either the constrained or full-width content
    final baseScaffold = Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor ?? AppTheme.backgroundLight,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      persistentFooterButtons: persistentFooterButtons,
      body: child,
    );

    // For desktop, constrain the width to 500px
    if (_isDesktop) {
      return Scaffold(
        backgroundColor: AppTheme.neutral100,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: baseScaffold,
          ),
        ),
      );
    } else {
      // For mobile, use the full screen
      return baseScaffold;
    }
  }
}

/// Extension to easily wrap any widget with the ResponsiveScreen
extension ResponsiveScreenExtension on Widget {
  Widget asResponsiveScreen({
    AppBar? appBar,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    Color? backgroundColor,
    bool extendBody = false,
    bool extendBodyBehindAppBar = false,
    List<Widget>? persistentFooterButtons,
  }) {
    return ResponsiveScreen(
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      backgroundColor: backgroundColor,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      persistentFooterButtons: persistentFooterButtons,
      child: this,
    );
  }
}

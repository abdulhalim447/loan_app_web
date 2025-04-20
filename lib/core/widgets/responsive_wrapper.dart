import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.backgroundColor,
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
    // For desktop, constrain the width to 500px
    if (_isDesktop) {
      return Scaffold(
        backgroundColor: backgroundColor ?? Colors.grey[100],
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
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
            height: double.infinity,
            child: child,
          ),
        ),
      );
    } else {
      // For mobile, use the full screen
      return child;
    }
  }
}

// Extension to easily wrap any widget with the ResponsiveWrapper
extension ResponsiveWidgetExtension on Widget {
  Widget responsive({Color? backgroundColor}) {
    return ResponsiveWrapper(
      backgroundColor: backgroundColor,
      child: this,
    );
  }
}

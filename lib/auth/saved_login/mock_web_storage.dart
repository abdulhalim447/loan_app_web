/// A mock implementation of WebStorage for non-web platforms.
///
/// This class is a no-op implementation that allows the same code to be used
/// across web and non-web platforms without conditional imports.
class WebStorage {
  /// Does nothing on non-web platforms
  static void setItem(String key, String value) {
    // No-op for non-web
  }

  /// Returns null on non-web platforms
  static String? getItem(String key) {
    return null;
  }

  /// Does nothing on non-web platforms
  static void removeItem(String key) {
    // No-op for non-web
  }

  /// Does nothing on non-web platforms
  static void clear() {
    // No-op for non-web
  }
}

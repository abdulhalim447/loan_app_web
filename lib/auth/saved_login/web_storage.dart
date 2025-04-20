import 'dart:html' as html;

/// A utility class for localStorage access when running on web.
class WebStorage {
  /// Sets an item in localStorage
  static void setItem(String key, String value) {
    html.window.localStorage[key] = value;
  }

  /// Gets an item from localStorage
  static String? getItem(String key) {
    return html.window.localStorage[key];
  }

  /// Removes an item from localStorage
  static void removeItem(String key) {
    html.window.localStorage.remove(key);
  }

  /// Clears all localStorage
  static void clear() {
    html.window.localStorage.clear();
  }
}

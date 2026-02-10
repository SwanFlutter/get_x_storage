// This file is used as a stub for non-web platforms
// It provides empty implementations of web-specific functionality

/// Stub implementation of WebStorageImpl for non-web platforms
class WebStorageImpl {
  /// Stub implementation of localStorage that returns null
  static dynamic get localStorage => null;

  /// Always returns false on non-web platforms
  static bool get isAvailable => false;

  /// Stub implementation of getItemSync that returns null
  static String? getItemSync(String key) => null;

  /// Stub implementation of setItemSync that does nothing
  static void setItemSync(String key, String value) {}

  /// Stub implementation of removeItemSync that does nothing
  static void removeItemSync(String key) {}
}

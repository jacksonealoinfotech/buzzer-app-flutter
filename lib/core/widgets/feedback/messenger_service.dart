import 'package:flutter/material.dart';

/// Global messenger service to display snackbars, banners, and bottom sheets
/// from business logic without requiring local [BuildContext].
abstract final class MessengerService {
  /// Global scaffold messenger key attached to root [MaterialApp].
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Global root navigator key attached to router.
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  /// Displays an ephemeral floating [SnackBar].
  static void showSnackBar({
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final state = scaffoldMessengerKey.currentState;
    if (state == null) return;

    state.hideCurrentSnackBar();
    state.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: isError ? Colors.red.shade800 : null,
      ),
    );
  }

  /// Displays an error toast/snackbar.
  static void showError(String message) {
    showSnackBar(message: message, isError: true);
  }

  /// Displays a success toast/snackbar.
  static void showSuccess(String message) {
    showSnackBar(message: message);
  }

  /// Shows a modal bottom sheet using the root navigator.
  static Future<T?> showBottomSheet<T>({
    required WidgetBuilder builder,
    bool isDismissible = true,
  }) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return Future.value(null);

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      builder: builder,
    );
  }
}

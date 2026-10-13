import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Modal dialog helpers with platform-adaptive presentation.
abstract final class AppDialogs {
  /// Displays an adaptive confirmation dialog (Cupertino on iOS, Material 3 elsewhere).
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIos) {
      final result = await showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(cancelText),
            ),
            CupertinoDialogAction(
              isDestructiveAction: isDestructive,
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(confirmText),
            ),
          ],
        ),
      );
      return result ?? false;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Displays non-dismissible force update modal.
  static Future<void> showForceUpdateDialog({
    required BuildContext context,
    required String updateUrl,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Update Required'),
          content: const Text(
            'A required update is available. Please update to the latest version to continue using the app.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                // TODO: Launch updateUrl via url_launcher
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays permission rationale dialog.
  static Future<bool> showPermissionRationaleDialog({
    required BuildContext context,
    required String permissionName,
    required String rationale,
  }) async {
    return showConfirmDialog(
      context: context,
      title: '$permissionName Permission Required',
      message: rationale,
      confirmText: 'Grant Permission',
      cancelText: 'Not Now',
    );
  }
}

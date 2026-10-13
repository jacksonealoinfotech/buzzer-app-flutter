import 'package:flutter/material.dart';

/// Base screen scaffold providing:
/// - Tap outside to dismiss on-screen software keyboard.
/// - SafeArea management.
/// - Full-screen blocking loading overlay.
/// - Optional pull-to-refresh integration.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    super.key,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.drawer,
    this.isLoading = false,
    this.onRefresh,
    this.useSafeArea = true,
    this.dismissKeyboardOnTap = true,
    this.backgroundColor,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final bool isLoading;
  final Future<void> Function()? onRefresh;
  final bool useSafeArea;
  final bool dismissKeyboardOnTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    // Pull-to-refresh
    if (onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    // Safe Area
    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    // Dismiss keyboard on background tap
    if (dismissKeyboardOnTap) {
      content = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: content,
      );
    }

    // Loading overlay
    if (isLoading) {
      content = Stack(
        children: [
          content,
          const Positioned.fill(
            child: ModalBarrier(
              dismissible: false,
              color: Colors.black26,
            ),
          ),
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      backgroundColor: backgroundColor,
    );
  }
}

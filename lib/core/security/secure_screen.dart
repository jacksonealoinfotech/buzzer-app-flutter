import 'dart:ui';
import 'package:flutter/material.dart';

// TODO: Uncomment when native screen security package (e.g., `screen_protector`) is added:
// import 'package:screen_protector/screen_protector.dart';

/// Wraps sensitive views (e.g. Card details, Seed phrases, Authentication screens)
/// to prevent shoulder-surfing and recents task switcher leakage:
/// - Blurs content when app transitions to inactive or background state (iOS App Switcher).
/// - Provides hooks for Android `FLAG_SECURE` window flags.
class SecureScreen extends StatefulWidget {
  const SecureScreen({
    required this.child,
    super.key,
    this.enableBlurOnBackground = true,
    this.blurSigma = 20.0,
  });

  final Widget child;
  final bool enableBlurOnBackground;
  final double blurSigma;

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen>
    with WidgetsBindingObserver {
  bool _isBackgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // TODO: Uncomment for native FLAG_SECURE on Android:
    // ScreenProtector.protectDataLeakageOn();
  }

  @override
  void dispose() {
    // TODO: Uncomment to release native screen protection:
    // ScreenProtector.protectDataLeakageOff();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enableBlurOnBackground) return;

    final shouldBlur = state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden;

    if (shouldBlur != _isBackgrounded) {
      setState(() {
        _isBackgrounded = shouldBlur;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        if (_isBackgrounded)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blurSigma,
                sigmaY: widget.blurSigma,
              ),
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                child: const Center(
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

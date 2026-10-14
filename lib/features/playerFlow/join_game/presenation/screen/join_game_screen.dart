import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buzzer_app/core/router/app_routes.dart';

/// Buzzer – Join a Game screen (player flow).
///
/// • Uses ONLY `Theme.of(context).colorScheme` → light/dark works automatically.
/// • Requires Flutter 3.27+ (`Color.withValues`). On older versions replace
///   `.withValues(alpha: x)` with `.withOpacity(x)`.
class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({
    super.key,
    this.onJoin,
    this.onGetInvited,
    this.codeLength = 5,
  });

  /// Validate the code with your backend and navigate to the lobby.
  /// Throw an exception when the code is invalid / game not found.
  final Future<void> Function(String code)? onJoin;

  /// Called when the user taps "Get invited".
  final VoidCallback? onGetInvited;

  /// Number of characters in a game code (design example "7FSK9" = 5).
  final int codeLength;

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen>
    with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  late final AnimationController _entrance;
  late final AnimationController _float;
  late final AnimationController _shake;

  late final Animation<double> _backAnim;
  late final Animation<double> _logoAnim;
  late final Animation<double> _titleAnim;
  late final Animation<double> _fieldAnim;
  late final Animation<double> _buttonAnim;
  late final Animation<double> _footerAnim;

  bool _loading = false;
  String? _error;

  bool get _complete => _ctrl.text.length == widget.codeLength;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    Animation<double> stagger(double b, double e) => CurvedAnimation(
      parent: _entrance,
      curve: Interval(b, e, curve: Curves.easeOutCubic),
    );

    _backAnim = stagger(0.0, 0.3);
    _logoAnim = stagger(0.05, 0.45);
    _titleAnim = stagger(0.20, 0.55);
    _fieldAnim = stagger(0.35, 0.72);
    _buttonAnim = stagger(0.48, 0.85);
    _footerAnim = stagger(0.62, 1.0);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    _shake.dispose();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _demoJoin(String code) =>
      Future.delayed(const Duration(milliseconds: 1200));

  void _fail(String message) {
    HapticFeedback.mediumImpact();
    _shake.forward(from: 0);
    setState(() => _error = message);
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    const GameLobbyRoute().push<void>(context);
    // if (!_complete) {
    //   _fail('Enter the full ${widget.codeLength}-character game code');
    //   return;
    // }

    // setState(() {
    //   _loading = true;
    //   _error = null;
    // });
    // try {
    //   await (widget.onJoin ?? _demoJoin)(_ctrl.text);
    //   // TODO: navigate to the waiting lobby screen
    // } catch (e) {
    //   if (!mounted) return;
    //   _fail('Game not found. Check the code and try again.');
    // } finally {
    //   if (mounted) setState(() => _loading = false);
    // }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    var pasted = (data?.text ?? '')
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase();
    if (pasted.isEmpty) return;
    if (pasted.length > widget.codeLength) {
      pasted = pasted.substring(0, widget.codeLength);
    }
    HapticFeedback.selectionClick();
    _ctrl.value = TextEditingValue(
      text: pasted,
      selection: TextSelection.collapsed(offset: pasted.length),
    );
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.6);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          _Background(animation: _float),
          SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back

                        const SizedBox(height: 16),

                        // Logo (floating)
                        Center(
                          child: _Reveal(
                            animation: _logoAnim,
                            child: AnimatedBuilder(
                              animation: _float,
                              builder: (context, child) {
                                final dy = math.sin(_float.value * math.pi) * 5;
                                return Transform.translate(
                                  offset: Offset(0, -dy),
                                  child: child,
                                );
                              },
                              child: const _BuzzerLogo(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        _Reveal(
                          animation: _titleAnim,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Join a Game',
                                style: text.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Enter the game code to participate in a live competition.',
                                style: text.bodyMedium?.copyWith(
                                  color: muted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Game code field (shakes on error)
                        _Reveal(
                          animation: _fieldAnim,
                          child: AnimatedBuilder(
                            animation: _shake,
                            builder: (context, child) {
                              final t = _shake.value;
                              final dx =
                                  math.sin(t * math.pi * 5) * 10 * (1 - t);
                              return Transform.translate(
                                offset: Offset(dx, 0),
                                child: child,
                              );
                            },
                            child: _GlowField(
                              focusNode: _focus,
                              hasError: _error != null,
                              child: ListenableBuilder(
                                listenable: _ctrl,
                                builder: (context, _) => TextField(
                                  controller: _ctrl,
                                  focusNode: _focus,
                                  enabled: !_loading,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  textInputAction: TextInputAction.done,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  keyboardType: TextInputType.visiblePassword,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[A-Za-z0-9]'),
                                    ),
                                    _UpperCaseFormatter(),
                                    LengthLimitingTextInputFormatter(
                                      widget.codeLength,
                                    ),
                                  ],
                                  style: TextStyle(
                                    color: cs.onSurface,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 4,
                                  ),
                                  onChanged: (_) {
                                    if (_error != null) {
                                      setState(() => _error = null);
                                    }
                                  },
                                  onSubmitted: (_) => _submit(),
                                  decoration: _decoration(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Join button
                        _Reveal(
                          animation: _buttonAnim,
                          child: ListenableBuilder(
                            listenable: _ctrl,
                            builder: (context, _) => _GradientButton(
                              label: 'Join Game',
                              loading: _loading,
                              dimmed: !_complete && !_loading,
                              onPressed: _loading ? null : _submit,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Footer
                        _Reveal(
                          animation: _footerAnim,
                          child: Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  "Don't have a code?",
                                  style: text.bodySmall?.copyWith(color: muted),
                                ),
                                TextButton(
                                  onPressed: _loading
                                      ? null
                                      : widget.onGetInvited,
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(0, 36),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    textStyle: text.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: const Text('Get invited'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    // Suffix: paste → counter → check
    Widget suffix;
    if (_ctrl.text.isEmpty) {
      suffix = IconButton(
        key: const ValueKey('paste'),
        tooltip: 'Paste code',
        onPressed: _loading ? null : _paste,
        icon: const Icon(Icons.content_paste_rounded),
      );
    } else if (_complete) {
      suffix = Padding(
        key: const ValueKey('done'),
        padding: const EdgeInsets.only(right: 14),
        child: Icon(Icons.check_circle_rounded, color: cs.primary),
      );
    } else {
      suffix = Padding(
        key: const ValueKey('count'),
        padding: const EdgeInsets.only(right: 16),
        child: Text(
          '${_ctrl.text.length}/${widget.codeLength}',
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return InputDecoration(
      labelText: 'Game code',
      hintText: 'e.g. 7FSK9',
      hintStyle: TextStyle(
        color: cs.onSurface.withValues(alpha: 0.35),
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      errorText: _error,
      prefixIcon: const Icon(Icons.pin_outlined),
      suffixIcon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (c, a) => ScaleTransition(
          scale: a,
          child: FadeTransition(opacity: a, child: c),
        ),
        child: suffix,
      ),
      suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      filled: true,
      fillColor: cs.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      border: border(cs.outlineVariant),
      enabledBorder: border(cs.outlineVariant),
      focusedBorder: border(cs.primary, 1.8),
      errorBorder: border(cs.error),
      focusedErrorBorder: border(cs.error, 1.8),
      disabledBorder: border(cs.outlineVariant.withValues(alpha: 0.5)),
      errorStyle: TextStyle(color: cs.error),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}

/// Fade + slide-up wrapper for staggered intro.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

/// Soft glow behind the field while it has focus (red when in error).
class _GlowField extends StatelessWidget {
  const _GlowField({
    required this.focusNode,
    required this.child,
    this.hasError = false,
  });

  final FocusNode focusNode;
  final Widget child;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        final glow = hasError ? cs.error : cs.primary;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: focusNode.hasFocus || hasError
                    ? glow.withValues(alpha: 0.18)
                    : cs.shadow.withValues(alpha: 0.04),
                blurRadius: focusNode.hasFocus || hasError ? 18 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Primary → tertiary gradient button. `dimmed` fades it while the form is
/// incomplete (still tappable so we can show a helpful error).
class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.dimmed = false,
  });

  final String label;
  final bool loading;
  final bool dimmed;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: dimmed ? 0.55 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(
                alpha: (loading || dimmed) ? 0.08 : 0.30,
              ),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.tertiary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: InkWell(
              onTap: onPressed,
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(scale: anim, child: child),
                    ),
                    child: loading
                        ? SizedBox(
                            key: const ValueKey('loader'),
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.6,
                              color: cs.onPrimary,
                            ),
                          )
                        : Text(
                            label,
                            key: const ValueKey('label'),
                            style: TextStyle(
                              color: cs.onPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bolt icon + "Buzzer" wordmark (stacked, centered like the design).
class _BuzzerLogo extends StatelessWidget {
  const _BuzzerLogo();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            colors: [cs.primary, cs.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(rect),
          child: const Icon(Icons.bolt_rounded, size: 56, color: Colors.white),
        ),
        Text(
          'Buzzer',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.5,
            color: cs.primary,
          ),
        ),
      ],
    );
  }
}

/// Two soft blurred blobs that slowly drift – built from theme colors.
class _Background extends StatelessWidget {
  const _Background({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget blob(Color color, double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0)],
        ),
      ),
    );

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(animation.value);
          return Stack(
            children: [
              Positioned(
                top: -80 + 30 * t,
                right: -90 + 20 * t,
                child: blob(cs.primaryContainer, 300),
              ),
              Positioned(
                bottom: -110 + 25 * (1 - t),
                left: -100 + 30 * t,
                child: blob(cs.tertiaryContainer, 320),
              ),
            ],
          );
        },
      ),
    );
  }
}

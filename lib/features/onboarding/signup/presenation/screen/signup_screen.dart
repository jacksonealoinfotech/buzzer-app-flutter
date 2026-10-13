import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Buzzer – Sign up (Create Your Account) screen.
///
/// • Uses ONLY `Theme.of(context).colorScheme` → light/dark works automatically.
/// • Requires Flutter 3.27+ (`Color.withValues`). On older versions replace
///   `.withValues(alpha: x)` with `.withOpacity(x)`.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, this.onSignUp, this.onSignIn});

  /// Plug your API / Firebase call here. Throw an exception to show an error.
  final Future<void> Function(String name, String email, String password)?
  onSignUp;

  /// Called when the user taps "Sign in" at the bottom.
  final VoidCallback? onSignIn;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  late final AnimationController _entrance;
  late final AnimationController _float;
  late final AnimationController _shake;

  late final Animation<double> _backAnim;
  late final Animation<double> _titleAnim;
  late final Animation<double> _nameAnim;
  late final Animation<double> _emailAnim;
  late final Animation<double> _passAnim;
  late final Animation<double> _buttonAnim;
  late final Animation<double> _footerAnim;

  bool _obscure = true;
  bool _loading = false;

  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

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
    _titleAnim = stagger(0.10, 0.45);
    _nameAnim = stagger(0.25, 0.60);
    _emailAnim = stagger(0.35, 0.70);
    _passAnim = stagger(0.45, 0.80);
    _buttonAnim = stagger(0.58, 0.92);
    _footerAnim = stagger(0.70, 1.0);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    _shake.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _demoSignUp(String name, String email, String password) =>
      Future.delayed(const Duration(milliseconds: 1500));

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      _shake.forward(from: 0);
      return;
    }

    setState(() => _loading = true);
    try {
      await (widget.onSignUp ?? _demoSignUp)(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      TextInput.finishAutofillContext();
      // TODO: navigate to home / verify email screen
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      _shake.forward(from: 0);
      _showError('Could not create your account. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: cs.errorContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: cs.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
      );
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
                        _Reveal(
                          animation: _backAnim,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () => Navigator.maybePop(context),
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: cs.onSurface,
                              tooltip: 'Back',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        _Reveal(
                          animation: _titleAnim,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Your Account',
                                style: text.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Start creating amazing competitions.',
                                style: text.bodyMedium?.copyWith(color: muted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Form (shakes on error)
                        AnimatedBuilder(
                          animation: _shake,
                          builder: (context, child) {
                            final t = _shake.value;
                            final dx = math.sin(t * math.pi * 5) * 10 * (1 - t);
                            return Transform.translate(
                              offset: Offset(dx, 0),
                              child: child,
                            );
                          },
                          child: AutofillGroup(
                            child: Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                children: [
                                  _Reveal(
                                    animation: _nameAnim,
                                    child: _GlowField(
                                      focusNode: _nameFocus,
                                      child: TextFormField(
                                        controller: _nameCtrl,
                                        focusNode: _nameFocus,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        keyboardType: TextInputType.name,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.name,
                                        ],
                                        enabled: !_loading,
                                        decoration: _decoration(
                                          context,
                                          label: 'Full name',
                                          hint: 'John Doe',
                                          icon: Icons.person_outline_rounded,
                                        ),
                                        validator: (v) {
                                          final value = v?.trim() ?? '';
                                          if (value.isEmpty) {
                                            return 'Please enter your name';
                                          }
                                          if (value.length < 2) {
                                            return 'Name is too short';
                                          }
                                          return null;
                                        },
                                        onFieldSubmitted: (_) =>
                                            _emailFocus.requestFocus(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _Reveal(
                                    animation: _emailAnim,
                                    child: _GlowField(
                                      focusNode: _emailFocus,
                                      child: TextFormField(
                                        controller: _emailCtrl,
                                        focusNode: _emailFocus,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.email,
                                        ],
                                        enabled: !_loading,
                                        decoration: _decoration(
                                          context,
                                          label: 'Email address',
                                          hint: 'you@company.com',
                                          icon: Icons.mail_outline_rounded,
                                        ),
                                        validator: (v) {
                                          final value = v?.trim() ?? '';
                                          if (value.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          if (!_emailRegex.hasMatch(value)) {
                                            return 'Enter a valid email address';
                                          }
                                          return null;
                                        },
                                        onFieldSubmitted: (_) =>
                                            _passFocus.requestFocus(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _Reveal(
                                    animation: _passAnim,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _GlowField(
                                          focusNode: _passFocus,
                                          child: TextFormField(
                                            controller: _passCtrl,
                                            focusNode: _passFocus,
                                            obscureText: _obscure,
                                            textInputAction:
                                                TextInputAction.done,
                                            autofillHints: const [
                                              AutofillHints.newPassword,
                                            ],
                                            enabled: !_loading,
                                            decoration: _decoration(
                                              context,
                                              label: 'Password',
                                              hint: '••••••••',
                                              icon: Icons.lock_outline_rounded,
                                              suffix: IconButton(
                                                tooltip: _obscure
                                                    ? 'Show password'
                                                    : 'Hide password',
                                                onPressed: () => setState(
                                                  () => _obscure = !_obscure,
                                                ),
                                                icon: AnimatedSwitcher(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  transitionBuilder: (c, a) =>
                                                      ScaleTransition(
                                                        scale: a,
                                                        child: c,
                                                      ),
                                                  child: Icon(
                                                    _obscure
                                                        ? Icons
                                                              .visibility_off_outlined
                                                        : Icons
                                                              .visibility_outlined,
                                                    key: ValueKey(_obscure),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            validator: (v) {
                                              if (v == null || v.isEmpty) {
                                                return 'Please create a password';
                                              }
                                              if (v.length < 8) {
                                                return 'Use at least 8 characters';
                                              }
                                              return null;
                                            },
                                            onFieldSubmitted: (_) => _submit(),
                                          ),
                                        ),
                                        _PasswordStrength(
                                          controller: _passCtrl,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Create account button
                        _Reveal(
                          animation: _buttonAnim,
                          child: _GradientButton(
                            label: 'Create Account',
                            loading: _loading,
                            onPressed: _loading ? null : _submit,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Footer
                        _Reveal(
                          animation: _footerAnim,
                          child: Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?',
                                  style: text.bodySmall?.copyWith(color: muted),
                                ),
                                TextButton(
                                  onPressed: _loading ? null : widget.onSignIn,
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(0, 36),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    textStyle: text.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: const Text('Sign in'),
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

  InputDecoration _decoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    final cs = Theme.of(context).colorScheme;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.35)),
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: cs.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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

/// Animated 4-segment password strength meter + label.
class _PasswordStrength extends StatelessWidget {
  const _PasswordStrength({required this.controller});

  final TextEditingController controller;

  static const _labels = ['Weak', 'Fair', 'Good', 'Strong'];

  int _score(String p) {
    var s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[a-z]').hasMatch(p) && RegExp(r'[A-Z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    if (p.length < 8) s = math.min(s, 1);
    return math.max(s, 1);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final colors = [cs.error, cs.secondary, cs.tertiary, cs.primary];

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = controller.text;
        final visible = p.isNotEmpty;
        final score = visible ? _score(p) : 0;
        final color = visible ? colors[score - 1] : cs.outlineVariant;

        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: !visible
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: List.generate(4, (i) {
                            final active = i < score;
                            return Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                height: 5,
                                margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: active
                                      ? color
                                      : cs.outlineVariant.withValues(
                                          alpha: 0.6,
                                        ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: (text.labelMedium ?? const TextStyle()).copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                        child: Text(_labels[score - 1]),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
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

/// Soft glow behind a field while it has focus.
class _GlowField extends StatelessWidget {
  const _GlowField({required this.focusNode, required this.child});

  final FocusNode focusNode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: focusNode.hasFocus
                    ? cs.primary.withValues(alpha: 0.18)
                    : cs.shadow.withValues(alpha: 0.04),
                blurRadius: focusNode.hasFocus ? 18 : 8,
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

/// Primary → tertiary gradient button with an animated loading state.
class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: loading ? 0.10 : 0.30),
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

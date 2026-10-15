import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onSignIn,
    this.onCreateAccount,
    this.onForgotPassword,
  });

  final Future<void> Function(String email, String password, bool remember)?
  onSignIn;
  final VoidCallback? onCreateAccount;
  final VoidCallback? onForgotPassword;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  late final AnimationController _entrance; // staggered intro
  late final AnimationController _float; // logo + background drift
  late final AnimationController _shake; // error shake

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _titleAnim;
  late final Animation<double> _emailAnim;
  late final Animation<double> _passAnim;
  late final Animation<double> _optionsAnim;
  late final Animation<double> _buttonAnim;
  late final Animation<double> _footerAnim;

  bool _obscure = true;
  bool _remember = true;
  bool _loading = false;

  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    Animation<double> stagger(double begin, double end) => CurvedAnimation(
      parent: _entrance,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );

    _logoScale = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
    );
    _logoFade = stagger(0.0, 0.25);
    _titleAnim = stagger(0.15, 0.50);
    _emailAnim = stagger(0.28, 0.62);
    _passAnim = stagger(0.38, 0.72);
    _optionsAnim = stagger(0.48, 0.82);
    _buttonAnim = stagger(0.58, 0.92);
    _footerAnim = stagger(0.70, 1.0);

    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    _shake.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _demoSignIn(String email, String password, bool remember) =>
      Future.delayed(const Duration(milliseconds: 1500));

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      await HapticFeedback.lightImpact();
      _shake.forward(from: 0);
      return;
    }

    setState(() => _loading = true);
    try {
      await (widget.onSignIn ?? _demoSignIn)(
        _emailCtrl.text.trim(),
        _passCtrl.text,
        _remember,
      );
      TextInput.finishAutofillContext();
      // TODO: navigate to home, e.g. Navigator.pushReplacement(...)
    } catch (e) {
      if (!mounted) return;
      await HapticFeedback.mediumImpact();
      _shake.forward(from: 0);
      _showError('Sign in failed. Please check your details and try again.');
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
          _AnimatedBackground(animation: _float),
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
                        // Back button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: cs.onSurface,
                            tooltip: 'Back',
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Logo
                        Center(
                          child: FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: AnimatedBuilder(
                                animation: _float,
                                builder: (context, child) {
                                  final dy =
                                      math.sin(_float.value * math.pi) * 6;
                                  return Transform.translate(
                                    offset: Offset(0, -dy),
                                    child: child,
                                  );
                                },
                                child: const _BuzzerLogo(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Title
                        _Reveal(
                          animation: _titleAnim,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back',
                                style: text.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Sign in to your quizz account',
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
                                    child: _GlowField(
                                      focusNode: _passFocus,
                                      child: TextFormField(
                                        controller: _passCtrl,
                                        focusNode: _passFocus,
                                        obscureText: _obscure,
                                        textInputAction: TextInputAction.done,
                                        autofillHints: const [
                                          AutofillHints.password,
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
                                                    : Icons.visibility_outlined,
                                                key: ValueKey(_obscure),
                                              ),
                                            ),
                                          ),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) {
                                            return 'Please enter your password';
                                          }
                                          if (v.length < 6) {
                                            return 'Password must be at least 6 characters';
                                          }
                                          return null;
                                        },
                                        onFieldSubmitted: (_) => _submit(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Remember me + Forgot password
                        _Reveal(
                          animation: _optionsAnim,
                          child: Row(
                            children: [
                              const Spacer(),
                              TextButton(
                                onPressed: _loading
                                    ? null
                                    : widget.onForgotPassword,
                                child: const Text('Forgot password?'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Sign in button
                        _Reveal(
                          animation: _buttonAnim,
                          child: _GradientButton(
                            label: 'Sign In',
                            loading: _loading,
                            onPressed: _loading ? null : _submit,
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
                                  "Don't have an account?",
                                  style: text.bodySmall?.copyWith(color: muted),
                                ),
                                TextButton(
                                  onPressed: _loading
                                      ? null
                                      : widget.onCreateAccount,
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(0, 36),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    textStyle: text.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: const Text('Create account'),
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
          begin: const Offset(0, 0.18),
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
                      : Row(
                          key: const ValueKey('label'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                color: cs.onPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: cs.onPrimary,
                              size: 20,
                            ),
                          ],
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

/// Bolt icon + "Buzzer" wordmark.
class _BuzzerLogo extends StatelessWidget {
  const _BuzzerLogo();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            colors: [cs.primary, cs.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(rect),
          child: const Icon(Icons.bolt_rounded, size: 44, color: Colors.white),
        ),
        const SizedBox(width: 4),
        Text(
          'Buzzer',
          style: TextStyle(
            fontSize: 30,
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
class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground({required this.animation});

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
          colors: [color.withValues(alpha: 0.55), color.withValues(alpha: 0)],
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

import 'dart:math' as math;

import 'package:buzzer_app/core/router/app_routes.dart';
import 'package:buzzer_app/core/security/secure_text_field.dart';
import 'package:buzzer_app/core/utils/enum.dart';
import 'package:buzzer_app/core/widgets/animations/glow_field.dart';
import 'package:buzzer_app/core/widgets/animations/reveal_animation.dart';
import 'package:buzzer_app/core/widgets/buttons/gradient_button.dart';
import 'package:buzzer_app/core/widgets/decorations/input_decoration.dart';
import 'package:buzzer_app/features/hostFlow/host_login/data/model/host_login_model.dart';
import 'package:buzzer_app/features/hostFlow/host_login/presenation/bloc/host_login_bloc.dart';
import 'package:buzzer_app/features/hostFlow/host_login/presenation/screen/widgets/animated_background.dart';
import 'package:buzzer_app/features/hostFlow/host_login/presenation/screen/widgets/buzzer_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HostLoginScreen extends StatefulWidget {
  const HostLoginScreen({
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
  State<HostLoginScreen> createState() => _HostLoginScreenState();
}

class _HostLoginScreenState extends State<HostLoginScreen>
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

  Future<void> _submit() async {
    context.read<HostLoginBloc>().add(
      LoginHostEvent(
        hostData: HostLoginModel(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        ),
      ),
    );
    // FocusScope.of(context).unfocus();
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
    final bloc = context.read<HostLoginBloc>();
    return BlocConsumer<HostLoginBloc, HostLoginState>(
      listener: (context, state) {
        if (state.status == RequestStatus.failure && state.errorMsg != null) {
          _showError(state.errorMsg!);
          bloc.add(ResetHostLoginState());
        }
        if (state.status == RequestStatus.completed) {
          const DashboardRoute().go(context);
        }
      },
      builder: (context, state) {
        bool loading = state.status == RequestStatus.loading;
        return Scaffold(
          backgroundColor: cs.surface,
          body: Stack(
            children: [
              AnimatedBackground(animation: _float),
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
                                    child: const BuzzerLogo(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Title
                            RevealAnimation(
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
                                    'Sign in to your host account',
                                    style: text.bodyMedium?.copyWith(
                                      color: muted,
                                    ),
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
                                final dx =
                                    math.sin(t * math.pi * 5) * 10 * (1 - t);
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
                                      RevealAnimation(
                                        animation: _emailAnim,
                                        child: GlowField(
                                          focusNode: _emailFocus,
                                          child: SecureTextField(
                                            controller: _emailCtrl,
                                            hintText: 'your@mail.com',
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            textInputAction:
                                                TextInputAction.next,
                                            autofillHints: const [
                                              AutofillHints.email,
                                            ],
                                            lable: 'Email Address',
                                            prefixIcon:
                                                Icons.mail_outline_rounded,

                                            validator: (v) {
                                              final value = v?.trim() ?? '';
                                              if (value.isEmpty) {
                                                return 'Please enter your email';
                                              }
                                              if (!_emailRegex.hasMatch(
                                                value,
                                              )) {
                                                return 'Enter a valid email address';
                                              }
                                              return null;
                                            },
                                            // onFieldSubmitted: (_) =>
                                            //     _passFocus.requestFocus(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      RevealAnimation(
                                        animation: _passAnim,
                                        child: GlowField(
                                          focusNode: _passFocus,
                                          child: TextFormField(
                                            controller: _passCtrl,
                                            focusNode: _passFocus,
                                            obscureText: _obscure,
                                            textInputAction:
                                                TextInputAction.done,
                                            autofillHints: const [
                                              AutofillHints.password,
                                            ],
                                            enabled: !loading,
                                            decoration: decoration(
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
                            RevealAnimation(
                              animation: _optionsAnim,
                              child: Row(
                                children: [
                                  const Spacer(),
                                  TextButton(
                                    onPressed: loading
                                        ? null
                                        : widget.onForgotPassword,
                                    child: const Text('Forgot password?'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Sign in button
                            RevealAnimation(
                              animation: _buttonAnim,
                              child: GradientButton(
                                label: 'Sign In',
                                loading: loading,
                                onPressed: loading ? null : _submit,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Footer
                            RevealAnimation(
                              animation: _footerAnim,
                              child: Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account?",
                                      style: text.bodySmall?.copyWith(
                                        color: muted,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: loading
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
      },
    );
  }
}

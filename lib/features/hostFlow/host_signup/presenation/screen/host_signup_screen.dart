import 'dart:math' as math;

import 'package:buzzer_app/core/router/app_routes.dart';
import 'package:buzzer_app/core/utils/enum.dart';
import 'package:buzzer_app/core/widgets/animations/glow_field.dart';
import 'package:buzzer_app/core/widgets/animations/reveal_animation.dart';
import 'package:buzzer_app/core/widgets/buttons/gradient_button.dart';
import 'package:buzzer_app/core/widgets/display/show_error_msg.dart';
import 'package:buzzer_app/features/hostFlow/host_signup/data/model/host_signup_model.dart';
import 'package:buzzer_app/features/hostFlow/host_signup/presenation/bloc/host_signup_bloc.dart';
import 'package:buzzer_app/features/hostFlow/host_signup/presenation/screen/widgets/host_signup_background.dart';
import 'package:buzzer_app/features/hostFlow/host_signup/presenation/screen/widgets/host_signup_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HostSignupScreen extends StatefulWidget {
  const HostSignupScreen({super.key, this.onSignUp, this.onSignIn});

  final Future<void> Function(String name, String email, String password)?
  onSignUp;

  final VoidCallback? onSignIn;

  @override
  State<HostSignupScreen> createState() => _HostSignupScreenState();
}

class _HostSignupScreenState extends State<HostSignupScreen>
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

  Future<void> _submit() async {
    context.read<HostSignupBloc>().add(
      SignupHostEvent(
        userData: HostSignupModel(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
          name: _nameCtrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.6);
    final bloc = context.read<HostSignupBloc>();
    return BlocConsumer<HostSignupBloc, HostSignupState>(
      listener: (context, state) {
        if (state.status == RequestStatus.completed) {
          const DashboardRoute().go(context);
        }
        if (state.status == RequestStatus.failure && state.errorMsg != null) {
          showError(state.errorMsg!, context);
          bloc.add(SignupResetEvent());
        }
      },
      builder: (context, state) {
        final loading = state.status == RequestStatus.loading;
        return Scaffold(
          backgroundColor: cs.surface,
          body: Stack(
            children: [
              HostSignupBackground(animation: _float),
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
                            RevealAnimation(
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
                            RevealAnimation(
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
                                        animation: _nameAnim,
                                        child: GlowField(
                                          focusNode: _nameFocus,
                                          child: TextFormField(
                                            controller: _nameCtrl,
                                            focusNode: _nameFocus,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            keyboardType: TextInputType.name,
                                            textInputAction:
                                                TextInputAction.next,
                                            autofillHints: const [
                                              AutofillHints.name,
                                            ],
                                            enabled: !loading,
                                            decoration: _decoration(
                                              context,
                                              label: 'Full name',
                                              hint: 'John Doe',
                                              icon:
                                                  Icons.person_outline_rounded,
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
                                      RevealAnimation(
                                        animation: _emailAnim,
                                        child: GlowField(
                                          focusNode: _emailFocus,
                                          child: TextFormField(
                                            controller: _emailCtrl,
                                            focusNode: _emailFocus,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            textInputAction:
                                                TextInputAction.next,
                                            autofillHints: const [
                                              AutofillHints.email,
                                            ],
                                            enabled: !loading,
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
                                              if (!_emailRegex.hasMatch(
                                                value,
                                              )) {
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
                                      RevealAnimation(
                                        animation: _passAnim,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            GlowField(
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
                                                enabled: !loading,
                                                decoration: _decoration(
                                                  context,
                                                  label: 'Password',
                                                  hint: '••••••••',
                                                  icon: Icons
                                                      .lock_outline_rounded,
                                                  suffix: IconButton(
                                                    tooltip: _obscure
                                                        ? 'Show password'
                                                        : 'Hide password',
                                                    onPressed: () => setState(
                                                      () =>
                                                          _obscure = !_obscure,
                                                    ),
                                                    icon: AnimatedSwitcher(
                                                      duration: const Duration(
                                                        milliseconds: 200,
                                                      ),
                                                      transitionBuilder:
                                                          (c, a) =>
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
                                                onFieldSubmitted: (_) =>
                                                    _submit(),
                                              ),
                                            ),
                                            HostSignupPassword(
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
                            RevealAnimation(
                              animation: _buttonAnim,
                              child: GradientButton(
                                label: 'Create Account',
                                loading: loading,
                                onPressed: loading ? null : _submit,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Footer
                            RevealAnimation(
                              animation: _footerAnim,
                              child: Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'Already have an account?',
                                      style: text.bodySmall?.copyWith(
                                        color: muted,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: loading
                                          ? null
                                          : widget.onSignIn,
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
      },
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

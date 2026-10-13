import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onFinished,
    this.duration = const Duration(milliseconds: 2800),
  });

  final VoidCallback onFinished;
  final Duration duration;

  /// Smooth fade transition you can use when leaving the splash.
  static Route<T> fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance; // one-time intro timeline
  late final AnimationController _ripple; // looping ripple rings
  late final AnimationController _float; // background drift + bolt glow

  late final Animation<double> _boltScale;
  late final Animation<double> _boltFade;
  late final Animation<double> _wordFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(vsync: this, duration: widget.duration);
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    Animation<double> interval(
      double b,
      double e, [
      Curve c = Curves.easeOutCubic,
    ]) => CurvedAnimation(
      parent: _entrance,
      curve: Interval(b, e, curve: c),
    );

    _boltScale = interval(0.0, 0.35, Curves.elasticOut);
    _boltFade = interval(0.0, 0.15);
    _wordFade = interval(0.25, 0.55);
    _taglineFade = interval(0.45, 0.75);
    _progress = interval(0.15, 1.0, Curves.easeInOut);

    _entrance.forward().whenComplete(() {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ripple.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Soft vertical gradient: surface → primaryContainer
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.surface,
                    cs.primaryContainer.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),

            _Orbs(animation: _float),

            // Logo + wordmark + tagline
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Expanding ripple rings
                        AnimatedBuilder(
                          animation: Listenable.merge([_ripple, _boltFade]),
                          builder: (context, _) {
                            return Opacity(
                              opacity: _boltFade.value,
                              child: Stack(
                                alignment: Alignment.center,
                                children: List.generate(2, (i) {
                                  final phase = (_ripple.value + i * 0.5) % 1.0;
                                  final size = 110 + 130 * phase;
                                  return Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: cs.primary.withValues(
                                          alpha: (1 - phase) * 0.28,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          },
                        ),

                        // Pulsing glow
                        AnimatedBuilder(
                          animation: _float,
                          builder: (context, _) {
                            final pulse =
                                0.85 + 0.15 * math.sin(_float.value * math.pi);
                            return FadeTransition(
                              opacity: _boltFade,
                              child: Container(
                                width: 190 * pulse,
                                height: 190 * pulse,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      cs.primary.withValues(alpha: 0.28),
                                      cs.primary.withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Bolt
                        FadeTransition(
                          opacity: _boltFade,
                          child: ScaleTransition(
                            scale: _boltScale,
                            child: ShaderMask(
                              shaderCallback: (rect) => LinearGradient(
                                colors: [cs.primary, cs.tertiary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(rect),
                              child: const Icon(
                                Icons.bolt_rounded,
                                size: 130,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Wordmark
                  FadeTransition(
                    opacity: _wordFade,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(_wordFade),
                      child: Text(
                        'Buzzer',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: -1,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tagline
                  FadeTransition(
                    opacity: _taglineFade,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.4),
                        end: Offset.zero,
                      ).animate(_taglineFade),
                      child: Text(
                        'Think. Answer. Compete.',
                        style: text.titleMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.75),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom progress line
            Positioned(
              left: 0,
              right: 0,
              bottom: 40 + MediaQuery.of(context).padding.bottom,
              child: Center(
                child: FadeTransition(
                  opacity: _boltFade,
                  child: _ProgressLine(animation: _progress),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 120,
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            Container(color: cs.outlineVariant.withValues(alpha: 0.6)),
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) => FractionallySizedBox(
                widthFactor: animation.value,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating orbs/blobs that drift slowly (like the concept board).
class _Orbs extends StatelessWidget {
  const _Orbs({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget blob(Color color, double size, {double strength = 0.55}) =>
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: strength),
                color.withValues(alpha: 0),
              ],
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
                top: -70 + 30 * t,
                right: -80 + 20 * t,
                child: blob(cs.primaryContainer, 300),
              ),
              Positioned(
                bottom: 40 + 25 * (1 - t),
                right: -70 + 30 * t,
                child: blob(cs.tertiaryContainer, 240),
              ),
              Positioned(
                bottom: -90 + 20 * t,
                left: -90 + 25 * (1 - t),
                child: blob(cs.secondaryContainer, 300, strength: 0.45),
              ),
              // Small floating dot, top-right
              Positioned(
                top: 150 + 12 * t,
                right: 70 - 10 * t,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.tertiary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

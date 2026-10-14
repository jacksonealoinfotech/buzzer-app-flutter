import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Buzzer – Quiz Result screen (shown right after the last question).
///
/// • Uses ONLY `Theme.of(context).colorScheme` → light/dark works automatically.
/// • Requires Flutter 3.27+ (`Color.withValues`, `PopScope.onPopInvokedWithResult`).
/// • Tap the trophy to replay the confetti 🎉
class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.rank,
    required this.totalPlayers,
    this.onViewLeaderboard,
    this.onPlayAgain,
    this.onBackHome,
  }) : assert(totalQuestions > 0);

  final int correctAnswers;
  final int totalQuestions;
  final int rank;
  final int totalPlayers;

  final VoidCallback? onViewLeaderboard;
  final VoidCallback? onPlayAgain;
  final VoidCallback? onBackHome;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;
  late final AnimationController _confetti;

  late final Animation<double> _trophyFade;
  late final Animation<double> _trophyScale;
  late final Animation<double> _titleAnim;
  late final Animation<double> _subtitleAnim;
  late final Animation<double> _ringFade;
  late final Animation<double> _ringProgress;
  late final Animation<double> _statsAnim;
  late final Animation<double> _buttonsAnim;

  late final List<_Particle> _particles;

  int get _percent =>
      (widget.correctAnswers / widget.totalQuestions * 100).round();
  bool get _celebrate => _percent >= 50;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _confetti = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );

    Animation<double> stagger(
      double b,
      double e, [
      Curve c = Curves.easeOutCubic,
    ]) => CurvedAnimation(
      parent: _entrance,
      curve: Interval(b, e, curve: c),
    );

    _trophyFade = stagger(0.0, 0.12);
    _trophyScale = stagger(0.0, 0.25, Curves.elasticOut);
    _titleAnim = stagger(0.10, 0.28);
    _subtitleAnim = stagger(0.16, 0.34);
    _ringFade = stagger(0.26, 0.42);
    _ringProgress = stagger(0.30, 0.75);
    _statsAnim = stagger(0.62, 0.84);
    _buttonsAnim = stagger(0.74, 1.0);

    final rnd = math.Random(11);
    _particles = List.generate(70, (_) => _Particle.random(rnd));

    if (_celebrate) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        HapticFeedback.mediumImpact();
        _confetti.forward();
      });
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    _confetti.dispose();
    super.dispose();
  }

  String _ordinal(int n) {
    final mod100 = n % 100;
    if (mod100 >= 11 && mod100 <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  String get _title {
    if (_percent >= 80) return 'Well Done!';
    if (_percent >= 50) return 'Good Job!';
    return 'Nice Try!';
  }

  void _goHome() => widget.onBackHome?.call();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.65);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      // Don't let the player go "back" into a finished quiz.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(statusBarColor: Colors.transparent),
        child: Scaffold(
          backgroundColor: cs.surface,
          body: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      cs.surface,
                      cs.primaryContainer.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
              _Orbs(animation: _float),

              SafeArea(
                child: CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Trophy
                                GestureDetector(
                                  onTap: _celebrate
                                      ? () {
                                          HapticFeedback.lightImpact();
                                          _confetti.forward(from: 0);
                                        }
                                      : null,
                                  child: FadeTransition(
                                    opacity: _trophyFade,
                                    child: ScaleTransition(
                                      scale: _trophyScale,
                                      child: _Trophy(animation: _float),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Title
                                _Reveal(
                                  animation: _titleAnim,
                                  child: Text(
                                    _title,
                                    style: text.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Subtitle
                                _Reveal(
                                  animation: _subtitleAnim,
                                  child: Text.rich(
                                    TextSpan(
                                      style: text.bodyMedium?.copyWith(
                                        color: muted,
                                      ),
                                      children: [
                                        const TextSpan(text: 'You answered '),
                                        TextSpan(
                                          text:
                                              '${widget.correctAnswers} out of ${widget.totalQuestions}',
                                          style: TextStyle(
                                            color: cs.onSurface,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const TextSpan(text: ' correctly.'),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // Score ring
                                FadeTransition(
                                  opacity: _ringFade,
                                  child: _ScoreRing(
                                    progress: _ringProgress,
                                    percent: _percent,
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // Rank + total players
                                _Reveal(
                                  animation: _statsAnim,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _StatCard(
                                          icon: Icons.emoji_events_rounded,
                                          background: cs.primaryContainer,
                                          foreground: cs.onPrimaryContainer,
                                          label: 'Rank',
                                          value: _ordinal(widget.rank),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: _StatCard(
                                          icon: Icons.groups_rounded,
                                          background: cs.tertiaryContainer,
                                          foreground: cs.onTertiaryContainer,
                                          label: 'Total Players',
                                          value: '${widget.totalPlayers}',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Buttons
                                _Reveal(
                                  animation: _buttonsAnim,
                                  child: Column(
                                    children: [
                                      TextButton(
                                        onPressed: widget.onBackHome,
                                        child: const Text('Back to Home'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Confetti overlay
              if (_celebrate)
                IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _confetti,
                    builder: (context, _) => CustomPaint(
                      size: Size.infinite,
                      painter: _ConfettiPainter(
                        progress: _confetti.value,
                        particles: _particles,
                        colors: [
                          cs.primary,
                          cs.secondary,
                          cs.tertiary,
                          cs.primaryContainer,
                          cs.tertiaryContainer,
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating trophy with a pulsing glow.
class _Trophy extends StatelessWidget {
  const _Trophy({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(animation.value);
        return Transform.translate(offset: Offset(0, -6 * t), child: child);
      },
      child: SizedBox(
        width: 170,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) => Container(
                width: 150 + 14 * animation.value,
                height: 150 + 14 * animation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      cs.primary.withValues(alpha: 0.25),
                      cs.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                colors: [cs.primary, cs.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(rect),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 120,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular score gauge that fills while the % counts up.
class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.progress, required this.percent});

  final Animation<double> progress;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SizedBox(
      width: 190,
      height: 190,
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          final v = progress.value;
          return CustomPaint(
            painter: _ScoreRingPainter(
              progress: v * percent / 100,
              track: cs.outlineVariant.withValues(alpha: 0.5),
              start: cs.primary,
              end: cs.tertiary,
              fill: cs.surfaceContainerLowest.withValues(alpha: 0.9),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(v * percent).round()}%',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                      height: 1.1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    'Your Score',
                    style: text.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({
    required this.progress,
    required this.track,
    required this.start,
    required this.end,
    required this.fill,
  });

  final double progress; // 0..1
  final Color track;
  final Color start;
  final Color end;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 13.0;
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - stroke * 1.2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(center, radius - stroke / 2, Paint()..color = fill);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    if (progress <= 0) return;
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    final shader = SweepGradient(
      colors: [start, end],
      transform: const GradientRotation(-math.pi / 2),
    ).createShader(rect);

    // Glow
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke + 6
        ..shader = shader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..color = start.withValues(alpha: 0.4),
    );
    // Arc
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke
        ..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter old) =>
      old.progress != progress ||
      old.track != track ||
      old.start != start ||
      old.end != end ||
      old.fill != fill;
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: background,
            ),
            child: Icon(icon, color: foreground, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  value,
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Primary → tertiary gradient button.
class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 7),
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
              height: 54,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: cs.onPrimary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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

/// Soft drifting glow blobs.
class _Orbs extends StatelessWidget {
  const _Orbs({required this.animation});

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
                top: -80 + 25 * t,
                left: -90 + 20 * t,
                child: blob(cs.tertiaryContainer, 300),
              ),
              Positioned(
                bottom: -100 + 25 * (1 - t),
                right: -90 + 25 * t,
                child: blob(cs.primaryContainer, 300),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ───────────────────────── Confetti ─────────────────────────

class _Particle {
  _Particle({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.sway,
    required this.swayFreq,
    required this.phase,
    required this.colorIndex,
    required this.isCircle,
  });

  factory _Particle.random(math.Random r) => _Particle(
    x: r.nextDouble(),
    delay: r.nextDouble() * 0.3,
    speed: 0.75 + r.nextDouble() * 0.35,
    size: 6 + r.nextDouble() * 7,
    rotation: r.nextDouble() * math.pi * 2,
    rotationSpeed: (r.nextDouble() - 0.5) * 14,
    sway: 10 + r.nextDouble() * 30,
    swayFreq: 1 + r.nextDouble() * 2,
    phase: r.nextDouble() * math.pi * 2,
    colorIndex: r.nextInt(5),
    isCircle: r.nextBool(),
  );

  final double x;
  final double delay;
  final double speed;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final double sway;
  final double swayFreq;
  final double phase;
  final int colorIndex;
  final bool isCircle;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.progress,
    required this.particles,
    required this.colors,
  });

  final double progress;
  final List<_Particle> particles;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    for (final p in particles) {
      final t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0 || t >= 1) continue;

      final y = -30 + (size.height + 60) * (0.6 * t + 0.4 * t * t) * p.speed;
      final x =
          p.x * size.width +
          math.sin(t * p.swayFreq * 2 * math.pi + p.phase) * p.sway;
      final opacity = t > 0.8 ? (1 - t) / 0.2 : 1.0;

      final paint = Paint()
        ..color = colors[p.colorIndex % colors.length].withValues(
          alpha: opacity.clamp(0.0, 1.0),
        );

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + t * p.rotationSpeed);
      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2.4, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.5,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress || old.colors != colors;
}

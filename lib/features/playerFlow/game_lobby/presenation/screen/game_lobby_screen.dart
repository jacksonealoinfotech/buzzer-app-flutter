import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A player shown in the lobby avatar stack.
class LobbyPlayer {
  const LobbyPlayer({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;
}

/// Buzzer – Game Lobby screen (player waits here until the host starts).
///
/// • Uses ONLY `Theme.of(context).colorScheme` → light/dark works automatically.
///   The concept board shows this screen in a dark, immersive look. To always
///   get that look, wrap it with your dark theme:
///   `Theme(data: AppTheme.dark, child: GameLobbyScreen(...))`
/// • Requires Flutter 3.27+ (`Color.withValues`, `PopScope.onPopInvokedWithResult`).
class GameLobbyScreen extends StatefulWidget {
  const GameLobbyScreen({
    super.key,
    required this.gameTitle,
    required this.participantCount,
    required this.maxParticipants,
    required this.gameMode,
    required this.questionDurationSeconds,
    required this.questionCount,
    this.players = const [],
    this.countdown = const Duration(seconds: 45),
    this.startsAt,
    this.onCountdownFinished,
    this.onLeave,
  });

  final String gameTitle;
  final int participantCount;
  final int maxParticipants;
  final String gameMode;
  final int questionDurationSeconds;
  final int questionCount;

  /// First few players for the avatar stack (max 4 are shown).
  final List<LobbyPlayer> players;

  /// Used when [startsAt] is null.
  final Duration countdown;

  /// Server start time – preferred, keeps every player in sync.
  final DateTime? startsAt;

  /// Called when the countdown reaches zero → navigate to the quiz screen.
  final VoidCallback? onCountdownFinished;

  /// Called after the user confirms leaving. Defaults to `Navigator.pop`.
  final VoidCallback? onLeave;

  @override
  State<GameLobbyScreen> createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends State<GameLobbyScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;
  late final AnimationController _wave;
  late final AnimationController _ring;
  late final ValueNotifier<int> _secondsLeft;
  late final Duration _total;

  late final Animation<double> _headerAnim;
  late final Animation<double> _statusAnim;
  late final Animation<double> _peopleAnim;
  late final Animation<double> _ringFade;
  late final Animation<double> _ringScale;
  late final Animation<double> _infoAnim;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    Animation<double> stagger(double b, double e) => CurvedAnimation(
      parent: _entrance,
      curve: Interval(b, e, curve: Curves.easeOutCubic),
    );

    _headerAnim = stagger(0.0, 0.35);
    _statusAnim = stagger(0.12, 0.45);
    _peopleAnim = stagger(0.22, 0.55);
    _ringFade = stagger(0.30, 0.65);
    _ringScale = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.30, 0.80, curve: Curves.easeOutBack),
    );
    _infoAnim = stagger(0.55, 1.0);

    // Countdown
    final raw = widget.startsAt != null
        ? widget.startsAt!.difference(DateTime.now())
        : widget.countdown;
    _total = raw.isNegative ? Duration.zero : raw;

    _ring = AnimationController(
      vsync: this,
      duration: _total == Duration.zero
          ? const Duration(milliseconds: 1)
          : _total,
    );
    _secondsLeft = ValueNotifier<int>(_secondsFor(0));
    _ring.addListener(_onTick);
    _ring.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        HapticFeedback.heavyImpact();
        widget.onCountdownFinished?.call();
      }
    });
    _ring.forward();
  }

  int _secondsFor(double value) =>
      ((1 - value) * _total.inMilliseconds / 1000).ceil();

  void _onTick() {
    final s = _secondsFor(_ring.value);
    if (s != _secondsLeft.value) {
      _secondsLeft.value = s;
      if (s > 0 && s <= 5) HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    _wave.dispose();
    _ring.dispose();
    _secondsLeft.dispose();
    super.dispose();
  }

  Future<void> _confirmLeave() async {
    final cs = Theme.of(context).colorScheme;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Leave this game?'),
        content: const Text("You'll need the game code to join again."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      if (widget.onLeave != null) {
        widget.onLeave!();
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.65);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo + leave
                        _Reveal(
                          animation: _headerAnim,
                          child: Row(
                            children: [
                              const _BuzzerLogo(),
                              const Spacer(),
                              IconButton(
                                tooltip: 'Leave game',
                                onPressed: _confirmLeave,
                                icon: const Icon(Icons.close_rounded),
                                color: cs.onSurface,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title + status
                        _Reveal(
                          animation: _statusAnim,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.gameTitle,
                                style: text.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _PulseDot(animation: _float),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Waiting for host to start...',
                                    style: text.bodyMedium?.copyWith(
                                      color: muted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Participants
                        _Reveal(
                          animation: _peopleAnim,
                          child: Row(
                            children: [
                              _AvatarStack(players: widget.players),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Row(
                                  children: [
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      transitionBuilder: (c, a) =>
                                          FadeTransition(
                                            opacity: a,
                                            child: SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(0, 0.5),
                                                end: Offset.zero,
                                              ).animate(a),
                                              child: c,
                                            ),
                                          ),
                                      child: Text(
                                        '${widget.participantCount}',
                                        key: ValueKey(widget.participantCount),
                                        style: text.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: cs.primary,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        '/${widget.maxParticipants} participants',
                                        overflow: TextOverflow.ellipsis,
                                        style: text.bodyMedium?.copyWith(
                                          color: muted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Countdown ring
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: FadeTransition(
                                opacity: _ringFade,
                                child: ScaleTransition(
                                  scale: _ringScale,
                                  child: _CountdownRing(
                                    ring: _ring,
                                    secondsLeft: _secondsLeft,
                                    floatAnimation: _float,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Game info
                        _Reveal(
                          animation: _infoAnim,
                          child: _InfoCard(
                            items: [
                              _InfoItem(
                                icon: Icons.adjust_rounded,
                                label: 'Game Mode',
                                value: widget.gameMode,
                              ),
                              _InfoItem(
                                icon: Icons.timer_outlined,
                                label: 'Duration',
                                value:
                                    '${widget.questionDurationSeconds} seconds',
                              ),
                              _InfoItem(
                                icon: Icons.quiz_outlined,
                                label: 'Questions',
                                value: '${widget.questionCount}',
                              ),
                            ],
                          ),
                        ),
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

/// Glowing circular countdown: ring depletes while the seconds tick.
class _CountdownRing extends StatelessWidget {
  const _CountdownRing({
    required this.ring,
    required this.secondsLeft,
    required this.floatAnimation,
  });

  final Animation<double> ring;
  final ValueNotifier<int> secondsLeft;
  final Animation<double> floatAnimation;

  String _format(int s) =>
      s >= 60 ? '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}' : '${s}s';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(260.0, constraints.maxWidth * 0.72);
        return SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: Listenable.merge([ring, floatAnimation]),
            builder: (context, child) {
              final pulse =
                  0.5 + 0.5 * math.sin(floatAnimation.value * math.pi);
              return CustomPaint(
                painter: _RingPainter(
                  progress: 1 - ring.value,
                  glow: 0.25 + 0.2 * pulse,
                  trackColor: cs.outlineVariant.withValues(alpha: 0.5),
                  startColor: cs.primary,
                  endColor: cs.tertiary,
                  innerFill: cs.surfaceContainerLow.withValues(alpha: 0.55),
                ),
                child: child,
              );
            },
            child: Center(
              child: ValueListenableBuilder<int>(
                valueListenable: secondsLeft,
                builder: (context, s, _) {
                  final urgent = s <= 5 && s > 0;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: Tween<double>(
                              begin: 1.3,
                              end: 1.0,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Text(
                          _format(s),
                          key: ValueKey(s),
                          style: TextStyle(
                            fontSize: size * 0.22,
                            fontWeight: FontWeight.w800,
                            color: urgent ? cs.tertiary : cs.onSurface,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'until start',
                        style: text.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.glow,
    required this.trackColor,
    required this.startColor,
    required this.endColor,
    required this.innerFill,
  });

  final double progress; // 1 → 0
  final double glow; // 0..1 glow strength
  final Color trackColor;
  final Color startColor;
  final Color endColor;
  final Color innerFill;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - stroke * 1.5;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Inner disc
    canvas.drawCircle(center, radius - stroke / 2, Paint()..color = innerFill);

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = trackColor,
    );

    if (progress <= 0) return;
    final sweep = 2 * math.pi * progress;
    final shader = SweepGradient(
      colors: [startColor, endColor],
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
        ..strokeWidth = stroke + 8
        ..shader = shader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
        ..color = startColor.withValues(alpha: glow),
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

    // Leading dot
    final angle = -math.pi / 2 + sweep;
    final dot = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    canvas.drawCircle(
      dot,
      stroke * 0.9,
      Paint()..color = endColor.withValues(alpha: 0.35),
    );
    canvas.drawCircle(dot, stroke * 0.45, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.glow != glow ||
      old.trackColor != trackColor ||
      old.startColor != startColor ||
      old.endColor != endColor ||
      old.innerFill != innerFill;
}

/// Overlapping avatar circles (max 4).
class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.players});

  final List<LobbyPlayer> players;

  static const double _size = 40;
  static const double _overlap = 12;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shown = players.take(4).toList();
    if (shown.isEmpty) {
      return Icon(Icons.groups_rounded, color: cs.primary, size: 32);
    }

    final bg = [
      (cs.primaryContainer, cs.onPrimaryContainer),
      (cs.secondaryContainer, cs.onSecondaryContainer),
      (cs.tertiaryContainer, cs.onTertiaryContainer),
      (cs.surfaceContainerHigh, cs.onSurface),
    ];

    final width = _size + (shown.length - 1) * (_size - _overlap);
    return SizedBox(
      width: width,
      height: _size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * (_size - _overlap),
              child: TweenAnimationBuilder<double>(
                key: ValueKey('${shown[i].name}-$i'),
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 400 + i * 120),
                curve: Curves.easeOutBack,
                builder: (context, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bg[i % bg.length].$1,
                    border: Border.all(color: cs.surface, width: 2.5),
                    image: shown[i].avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(shown[i].avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: shown[i].avatarUrl != null
                      ? null
                      : Text(
                          shown[i].name.isEmpty
                              ? '?'
                              : shown[i].name[0].toUpperCase(),
                          style: TextStyle(
                            color: bg[i % bg.length].$2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

/// Frosted card with Game Mode / Duration / Questions.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.items});

  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[i].icon, color: cs.primary, size: 22),
                    const SizedBox(height: 6),
                    Text(
                      items[i].label,
                      style: text.labelSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[i].value,
                      textAlign: TextAlign.center,
                      style: text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < items.length - 1)
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small pulsing "live" dot.
class _PulseDot extends StatelessWidget {
  const _PulseDot({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        return SizedBox(
          width: 18,
          height: 18,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 8 + 10 * t,
                height: 8 + 10 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.tertiary.withValues(alpha: 0.35 * (1 - t)),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.tertiary,
                ),
              ),
            ],
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
          child: const Icon(Icons.bolt_rounded, size: 30, color: Colors.white),
        ),
        const SizedBox(width: 2),
        Text(
          'Buzzer',
          style: TextStyle(
            fontSize: 22,
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

/// Drifting glow orbs (top-right like the concept board).
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
                top: -70 + 25 * t,
                right: -80 + 20 * t,
                child: blob(cs.tertiaryContainer, 280),
              ),
              Positioned(
                top: 120 + 10 * t,
                right: 40 - 10 * t,
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

/// Soft animated waves along the bottom edge.
class _WaveBottom extends StatelessWidget {
  const _WaveBottom({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 220,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) => CustomPaint(
            painter: _WavePainter(
              phase: animation.value * 2 * math.pi,
              colorA: cs.primary.withValues(alpha: 0.10),
              colorB: cs.tertiary.withValues(alpha: 0.10),
            ),
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.phase,
    required this.colorA,
    required this.colorB,
  });

  final double phase;
  final Color colorA;
  final Color colorB;

  Path _wave(Size size, double amp, double shift, double base) {
    final path = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 4) {
      final y =
          base + math.sin((x / size.width) * 2 * math.pi + phase + shift) * amp;
      path.lineTo(x, y);
    }
    return path
      ..lineTo(size.width, size.height)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _wave(size, 14, 0, size.height * 0.45),
      Paint()..color = colorA,
    );
    canvas.drawPath(
      _wave(size, 18, math.pi, size.height * 0.6),
      Paint()..color = colorB,
    );
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) =>
      old.phase != phase || old.colorA != colorA || old.colorB != colorB;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({
    super.key,
    required this.onHost,
    required this.onPlayer,
  });

  final VoidCallback onHost;
  final VoidCallback onPlayer;

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

enum _Role { host, player }

class _SelectionScreenState extends State<SelectionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;

  late final Animation<double> _logoAnim;
  late final Animation<double> _titleAnim;
  late final Animation<double> _hostAnim;
  late final Animation<double> _playerAnim;

  _Role? _selected;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    Animation<double> stagger(double b, double e) => CurvedAnimation(
      parent: _entrance,
      curve: Interval(b, e, curve: Curves.easeOutCubic),
    );

    _logoAnim = stagger(0.0, 0.4);
    _titleAnim = stagger(0.15, 0.55);
    _hostAnim = stagger(0.35, 0.80);
    _playerAnim = stagger(0.50, 1.0);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    super.dispose();
  }

  Future<void> _choose(_Role role) async {
    if (_selected != null) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = role);

    // Let the selection animation play before navigating.
    await Future.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    role == _Role.host ? widget.onHost() : widget.onPlayer();

    // Reset so the screen is usable again when the user comes back.
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _selected = null);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          _Background(animation: _float),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      _Reveal(animation: _logoAnim, child: const _BuzzerLogo()),
                      const SizedBox(height: 32),

                      // Title + subtitle
                      _Reveal(
                        animation: _titleAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose Your Role',
                              style: text.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Select how you want to play the game.',
                              style: text.bodyMedium?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Host card
                      _Reveal(
                        animation: _hostAnim,
                        child: _RoleCard(
                          floatAnimation: _float,
                          icon: Icons.workspace_premium_rounded,
                          iconBackground: cs.primaryContainer,
                          iconColor: cs.onPrimaryContainer,
                          title: 'Host',
                          description: 'Create games and manage competitions.',
                          buttonLabel: 'Continue as Host',
                          selected: _selected == _Role.host,
                          dimmed: _selected == _Role.player,
                          onTap: () => _choose(_Role.host),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Player card
                      _Reveal(
                        animation: _playerAnim,
                        child: _RoleCard(
                          floatAnimation: _float,
                          floatPhase: math.pi,
                          icon: Icons.sports_esports_rounded,
                          iconBackground: cs.tertiaryContainer,
                          iconColor: cs.onTertiaryContainer,
                          title: 'Player',
                          description:
                              'Join a competition and test your knowledge.',
                          buttonLabel: 'Join a Game',
                          selected: _selected == _Role.player,
                          dimmed: _selected == _Role.host,
                          onTap: () => _choose(_Role.player),
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
    );
  }
}

/// Role card: tap anywhere (or the button) to choose.
class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.floatAnimation,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.selected,
    required this.dimmed,
    required this.onTap,
    this.floatPhase = 0,
  });

  final Animation<double> floatAnimation;
  final double floatPhase;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String description;
  final String buttonLabel;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: widget.dimmed ? 0.5 : 1,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        scale: _pressed
            ? 0.97
            : widget.selected
            ? 1.02
            : 1.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.selected ? cs.primary : cs.outlineVariant,
                width: widget.selected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.selected
                      ? cs.primary.withValues(alpha: 0.22)
                      : cs.shadow.withValues(alpha: 0.06),
                  blurRadius: widget.selected ? 24 : 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Floating icon bubble
                    AnimatedBuilder(
                      animation: widget.floatAnimation,
                      builder: (context, child) {
                        final dy =
                            math.sin(
                              widget.floatAnimation.value * math.pi +
                                  widget.floatPhase,
                            ) *
                            3;
                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.iconBackground,
                          boxShadow: [
                            BoxShadow(
                              color: widget.iconBackground.withValues(
                                alpha: 0.6,
                              ),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          size: 32,
                          color: widget.iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: text.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.description,
                              style: text.bodyMedium?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.65),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Check badge pops in when selected
                    AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      scale: widget.selected ? 1 : 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primary,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _GradientButton(
                  label: widget.buttonLabel,
                  onPressed: widget.onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Primary → tertiary gradient button.
class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
              height: 52,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 15,
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
          child: const Icon(Icons.bolt_rounded, size: 34, color: Colors.white),
        ),
        const SizedBox(width: 2),
        Text(
          'Buzzer',
          style: TextStyle(
            fontSize: 24,
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

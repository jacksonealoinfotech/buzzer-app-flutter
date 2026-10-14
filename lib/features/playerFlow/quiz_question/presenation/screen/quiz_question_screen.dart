import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One quiz question.
class QuizQuestion {
  const QuizQuestion({
    required this.text,
    required this.options,
    this.correctIndex,
  }) : assert(options.length >= 2);

  final String text;
  final List<String> options;

  /// Optional. When set (and `showCorrectAnswer` is true) the right / wrong
  /// answer is revealed after the player submits.
  final int? correctIndex;
}

/// Buzzer – Quiz Question screen (one question at a time).
///
/// Flow: read question → pick an option → **Submit Answer** → the button turns
/// into **Next Question** (or **Finish** on the last one).
///
/// • Uses `Theme.of(context).colorScheme` for everything → light/dark works.
///   The only exception is the "correct / live" green, which isn't part of a
///   Material ColorScheme: pass [successColor] / [onSuccessColor] from your
///   AppColors (a fallback green is used otherwise).
/// • Requires Flutter 3.27+ (`Color.withValues`, `PopScope.onPopInvokedWithResult`).
class QuizQuestionScreen extends StatefulWidget {
  const QuizQuestionScreen({
    super.key,
    required this.gameTitle,
    required this.questions,
    required this.onFinished,
    this.secondsPerQuestion = 30,
    this.showCorrectAnswer = true,
    this.isLive = true,
    this.onAnswerSubmitted,
    this.onExit,
    this.successColor = const Color(0xFF16A34A),
    this.onSuccessColor = Colors.white,
  });

  final String gameTitle;
  final List<QuizQuestion> questions;

  /// Called after the last question with the chosen index per question
  /// (`null` = unanswered).
  final void Function(List<int?> answers) onFinished;

  final int secondsPerQuestion;
  final bool showCorrectAnswer;
  final bool isLive;

  /// Send the answer to your backend here.
  final void Function(
    int questionIndex,
    int? selectedIndex,
    Duration timeTaken,
  )?
  onAnswerSubmitted;

  /// Called after the user confirms leaving. Defaults to `Navigator.pop`.
  final VoidCallback? onExit;

  final Color successColor;
  final Color onSuccessColor;

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

enum _OptState { idle, selected, locked, correct, wrong, dimmed }

class _QuizQuestionScreenState extends State<QuizQuestionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;
  late final AnimationController _timer;
  final _secondsLeft = ValueNotifier<int>(0);
  final _scroll = ScrollController();

  late final Animation<double> _headerAnim;
  late final Animation<double> _progressAnim;
  late final Animation<double> _cardAnim;
  late final Animation<double> _buttonAnim;

  late final List<int?> _answers;
  int _index = 0;
  int? _selected;
  bool _submitted = false;
  bool _timedOut = false;

  QuizQuestion get _q => widget.questions[_index];
  bool get _isLast => _index == widget.questions.length - 1;

  @override
  void initState() {
    super.initState();

    _answers = List<int?>.filled(widget.questions.length, null);

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    Animation<double> stagger(double b, double e) => CurvedAnimation(
      parent: _entrance,
      curve: Interval(b, e, curve: Curves.easeOutCubic),
    );
    _headerAnim = stagger(0.0, 0.4);
    _progressAnim = stagger(0.1, 0.5);
    _cardAnim = stagger(0.25, 0.8);
    _buttonAnim = stagger(0.5, 1.0);

    _timer = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.secondsPerQuestion),
    );
    _secondsLeft.value = widget.secondsPerQuestion;
    _timer.addListener(_onTick);
    _timer.addStatusListener((s) {
      if (s == AnimationStatus.completed) _onTimeUp();
    });
    _timer.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    _timer.dispose();
    _secondsLeft.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ───────────────────────── Logic ─────────────────────────

  void _onTick() {
    final s = ((1 - _timer.value) * widget.secondsPerQuestion).ceil();
    if (s != _secondsLeft.value) {
      _secondsLeft.value = s;
      if (!_submitted && s > 0 && s <= 5) HapticFeedback.lightImpact();
    }
  }

  void _onTimeUp() {
    if (_submitted || !mounted) return;
    _commit(timeUp: true);
  }

  void _select(int i) {
    if (_submitted || _selected == i) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = i);
  }

  void _commit({bool timeUp = false}) {
    if (_submitted) return;
    _timer.stop();
    final taken = Duration(
      milliseconds: (widget.secondsPerQuestion * 1000 * _timer.value).round(),
    );
    HapticFeedback.mediumImpact();
    setState(() {
      _submitted = true;
      _timedOut = timeUp;
      _answers[_index] = _selected;
    });
    widget.onAnswerSubmitted?.call(_index, _selected, taken);
  }

  void _next() {
    if (_isLast) {
      widget.onFinished(List.unmodifiable(_answers));
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _submitted = false;
      _timedOut = false;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
    _secondsLeft.value = widget.secondsPerQuestion;
    _timer.forward(from: 0);
  }

  Future<void> _confirmExit() async {
    final cs = Theme.of(context).colorScheme;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Leave the game?'),
        content: const Text('Your progress in this game will be lost.'),
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
      if (widget.onExit != null) {
        widget.onExit!();
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  _OptState _stateFor(int i) {
    if (!_submitted)
      return _selected == i ? _OptState.selected : _OptState.idle;
    final reveal = widget.showCorrectAnswer && _q.correctIndex != null;
    if (reveal) {
      if (i == _q.correctIndex) return _OptState.correct;
      if (i == _selected) return _OptState.wrong;
      return _OptState.dimmed;
    }
    return i == _selected ? _OptState.locked : _OptState.dimmed;
  }

  // ───────────────────────── UI ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = widget.questions.length;

    final canSubmit = !_submitted && _selected != null;
    final buttonLabel = !_submitted
        ? 'Submit Answer'
        : (_isLast ? 'Finish' : 'Next Question');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
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
                      cs.primaryContainer.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
              _Orbs(animation: _float),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      children: [
                        // Header
                        _Reveal(
                          animation: _headerAnim,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
                            child: Row(
                              children: [
                                IconButton(
                                  tooltip: 'Leave game',
                                  onPressed: _confirmExit,
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  color: cs.onSurface,
                                ),
                                Expanded(
                                  child: Text(
                                    widget.gameTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                                if (widget.isLive) ...[
                                  const SizedBox(width: 8),
                                  _LiveBadge(
                                    color: widget.successColor,
                                    onColor: widget.onSuccessColor,
                                    animation: _float,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Question progress
                        _Reveal(
                          animation: _progressAnim,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _StepProgress(value: (_index + 1) / total),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Question card
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scroll,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _Reveal(
                              animation: _cardAnim,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 380),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                layoutBuilder: (current, previous) => Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    ...previous,
                                    if (current != null) current,
                                  ],
                                ),
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(
                                      opacity: anim,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.12, 0),
                                          end: Offset.zero,
                                        ).animate(anim),
                                        child: child,
                                      ),
                                    ),
                                child: _QuestionCard(
                                  key: ValueKey(_index),
                                  index: _index,
                                  total: total,
                                  question: _q,
                                  timer: _timer,
                                  secondsLeft: _secondsLeft,
                                  stateFor: _stateFor,
                                  onSelect: _select,
                                  successColor: widget.successColor,
                                  onSuccessColor: widget.onSuccessColor,
                                  submitted: _submitted,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Feedback + action button
                        _Reveal(
                          animation: _buttonAnim,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                  alignment: Alignment.topCenter,
                                  child: _submitted
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: _FeedbackRow(
                                            key: ValueKey('fb$_index'),
                                            timedOut: _timedOut,
                                            hasAnswer: _selected != null,
                                            reveal:
                                                widget.showCorrectAnswer &&
                                                _q.correctIndex != null,
                                            isCorrect:
                                                _selected != null &&
                                                _selected == _q.correctIndex,
                                            correctLetter:
                                                _q.correctIndex == null
                                                ? null
                                                : String.fromCharCode(
                                                    65 + _q.correctIndex!,
                                                  ),
                                            successColor: widget.successColor,
                                          ),
                                        )
                                      : const SizedBox(width: double.infinity),
                                ),
                                _GradientButton(
                                  label: buttonLabel,
                                  trailing: _submitted
                                      ? Icons.arrow_forward_rounded
                                      : Icons.check_rounded,
                                  dimmed: !_submitted && !canSubmit,
                                  onPressed: _submitted
                                      ? _next
                                      : (canSubmit ? _commit : null),
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
            ],
          ),
        ),
      ),
    );
  }
}

/// White-ish card: counter + timer, question and A–D options.
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    super.key,
    required this.index,
    required this.total,
    required this.question,
    required this.timer,
    required this.secondsLeft,
    required this.stateFor,
    required this.onSelect,
    required this.successColor,
    required this.onSuccessColor,
    required this.submitted,
  });

  final int index;
  final int total;
  final QuizQuestion question;
  final AnimationController timer;
  final ValueNotifier<int> secondsLeft;
  final _OptState Function(int) stateFor;
  final ValueChanged<int> onSelect;
  final Color successColor;
  final Color onSuccessColor;
  final bool submitted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Counter + timer
          Row(
            children: [
              Text(
                '${index + 1}/$total',
                style: text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
              const Spacer(),
              _TimerChip(
                timer: timer,
                secondsLeft: secondsLeft,
                frozen: submitted,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _TimerBar(timer: timer, secondsLeft: secondsLeft),
          const SizedBox(height: 22),

          // Question
          Text(
            question.text,
            style: text.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 22),

          // Options
          for (var i = 0; i < question.options.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == question.options.length - 1 ? 0 : 12,
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 350 + i * 110),
                curve: Curves.easeOutCubic,
                builder: (context, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - v)),
                    child: child,
                  ),
                ),
                child: _OptionTile(
                  letter: String.fromCharCode(65 + i),
                  label: question.options[i],
                  state: stateFor(i),
                  successColor: successColor,
                  onSuccessColor: onSuccessColor,
                  onTap: () => onSelect(i),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatefulWidget {
  const _OptionTile({
    required this.letter,
    required this.label,
    required this.state,
    required this.onTap,
    required this.successColor,
    required this.onSuccessColor,
  });

  final String letter;
  final String label;
  final _OptState state;
  final VoidCallback onTap;
  final Color successColor;
  final Color onSuccessColor;

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    Color bg = cs.surfaceContainerLow;
    Color border = cs.outlineVariant;
    double borderWidth = 1;
    Color badgeBg = cs.surfaceContainerHigh;
    Color badgeFg = cs.onSurface;
    Color fg = cs.onSurface;
    IconData? trailing;
    Color trailingColor = cs.primary;
    double opacity = 1;

    switch (widget.state) {
      case _OptState.idle:
        break;
      case _OptState.selected:
        bg = cs.primaryContainer.withValues(alpha: 0.55);
        border = cs.primary;
        borderWidth = 2;
        badgeBg = cs.primary;
        badgeFg = cs.onPrimary;
        trailing = Icons.radio_button_checked_rounded;
        trailingColor = cs.primary;
        break;
      case _OptState.locked:
        bg = cs.primary;
        border = cs.primary;
        badgeBg = cs.onPrimary.withValues(alpha: 0.2);
        badgeFg = cs.onPrimary;
        fg = cs.onPrimary;
        trailing = Icons.check_rounded;
        trailingColor = cs.onPrimary;
        break;
      case _OptState.correct:
        bg = widget.successColor;
        border = widget.successColor;
        badgeBg = widget.onSuccessColor.withValues(alpha: 0.22);
        badgeFg = widget.onSuccessColor;
        fg = widget.onSuccessColor;
        trailing = Icons.check_rounded;
        trailingColor = widget.onSuccessColor;
        break;
      case _OptState.wrong:
        bg = cs.error;
        border = cs.error;
        badgeBg = cs.onError.withValues(alpha: 0.22);
        badgeFg = cs.onError;
        fg = cs.onError;
        trailing = Icons.close_rounded;
        trailingColor = cs.onError;
        break;
      case _OptState.dimmed:
        opacity = 0.5;
        break;
    }

    final highlighted =
        widget.state == _OptState.correct ||
        widget.state == _OptState.wrong ||
        widget.state == _OptState.locked;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: opacity,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        scale: _pressed ? 0.97 : 1,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: borderWidth),
              boxShadow: highlighted
                  ? [
                      BoxShadow(
                        color: bg.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.letter,
                    style: TextStyle(
                      color: badgeFg,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: (text.bodyLarge ?? const TextStyle()).copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Text(widget.label),
                  ),
                ),
                AnimatedScale(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.elasticOut,
                  scale: trailing == null ? 0 : 1,
                  child: Icon(
                    trailing ?? Icons.check_rounded,
                    color: trailingColor,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "00:28" pill – turns tertiary at ≤10s and error + pulsing at ≤5s.
class _TimerChip extends StatelessWidget {
  const _TimerChip({
    required this.timer,
    required this.secondsLeft,
    required this.frozen,
  });

  final Animation<double> timer;
  final ValueNotifier<int> secondsLeft;
  final bool frozen;

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ValueListenableBuilder<int>(
      valueListenable: secondsLeft,
      builder: (context, s, _) {
        final urgent = !frozen && s <= 5;
        final warn = !frozen && s <= 10;
        final color = urgent
            ? cs.error
            : warn
            ? cs.tertiary
            : cs.onSurface.withValues(alpha: 0.75);

        return AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: urgent && s.isOdd ? 1.08 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  _fmt(s),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Thin bar that drains as the time runs out.
class _TimerBar extends StatelessWidget {
  const _TimerBar({required this.timer, required this.secondsLeft});

  final Animation<double> timer;
  final ValueNotifier<int> secondsLeft;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: timer,
      builder: (context, _) {
        final s = secondsLeft.value;
        final color = s <= 5
            ? cs.error
            : s <= 10
            ? cs.tertiary
            : cs.primary;
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 1 - timer.value,
            minHeight: 5,
            color: color,
            backgroundColor: cs.outlineVariant.withValues(alpha: 0.5),
          ),
        );
      },
    );
  }
}

/// Top question-progress bar (animates between steps).
class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          height: 7,
          child: Stack(
            children: [
              Container(color: cs.outlineVariant.withValues(alpha: 0.5)),
              FractionallySizedBox(
                widthFactor: v.clamp(0.0, 1.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({
    required this.color,
    required this.onColor,
    required this.animation,
  });

  final Color color;
  final Color onColor;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) => Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: onColor.withValues(alpha: 0.5 + 0.5 * animation.value),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Live',
            style: TextStyle(
              color: onColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Correct!" / "Incorrect" / "Time's up" message after submitting.
class _FeedbackRow extends StatelessWidget {
  const _FeedbackRow({
    super.key,
    required this.timedOut,
    required this.hasAnswer,
    required this.reveal,
    required this.isCorrect,
    required this.correctLetter,
    required this.successColor,
  });

  final bool timedOut;
  final bool hasAnswer;
  final bool reveal;
  final bool isCorrect;
  final String? correctLetter;
  final Color successColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    late final IconData icon;
    late final String message;
    late final Color color;

    if (timedOut && !hasAnswer) {
      icon = Icons.timer_off_outlined;
      message = reveal && correctLetter != null
          ? "Time's up! The answer was $correctLetter."
          : "Time's up! No answer submitted.";
      color = cs.error;
    } else if (reveal) {
      if (isCorrect) {
        icon = Icons.check_circle_rounded;
        message = timedOut ? "Time's up – and that's correct!" : 'Correct!';
        color = successColor;
      } else {
        icon = Icons.cancel_rounded;
        message = 'Incorrect – the answer is $correctLetter.';
        color = cs.error;
      }
    } else {
      icon = Icons.check_circle_outline_rounded;
      message = timedOut
          ? "Time's up! Your answer was submitted."
          : 'Answer submitted.';
      color = cs.primary;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.9 + 0.1 * v, child: child),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Primary → tertiary gradient button (dimmed = not ready yet).
class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.trailing,
    required this.onPressed,
    this.dimmed = false,
  });

  final String label;
  final IconData trailing;
  final bool dimmed;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: dimmed ? 0.5 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: dimmed ? 0.06 : 0.30),
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
                    child: Row(
                      key: ValueKey(label),
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
                        Icon(trailing, color: cs.onPrimary, size: 20),
                      ],
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
          begin: const Offset(0, 0.12),
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
                right: -90 + 20 * t,
                child: blob(cs.tertiaryContainer, 300),
              ),
              Positioned(
                bottom: -100 + 25 * (1 - t),
                left: -90 + 25 * t,
                child: blob(cs.primaryContainer, math.max(280, 300)),
              ),
            ],
          );
        },
      ),
    );
  }
}

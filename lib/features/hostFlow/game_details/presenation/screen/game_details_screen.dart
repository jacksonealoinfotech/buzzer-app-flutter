import 'package:buzzer_app/features/hostFlow/host_dashboard/presenation/screen/host_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ───────────────────────── Models ─────────────────────────

class GameQuestion {
  const GameQuestion({
    required this.text,
    required this.options,
    this.correctIndex,
  });

  final String text;
  final List<String> options;
  final int? correctIndex;
}

class GameParticipant {
  const GameParticipant({
    required this.name,
    this.avatarUrl,
    this.registeredAt,
  });

  final String name;
  final String? avatarUrl;
  final DateTime? registeredAt;
}

class GameDetails {
  const GameDetails({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.mode,
    required this.status,
    required this.startsAt,
    required this.timeZone,
    required this.questionDurationSeconds,
    required this.openRegistration,
    required this.players,
    required this.maxPlayers,
    this.registrationOpens,
    this.registrationCloses,
    this.questions = const [],
    this.participants = const [],
  });

  final String id;

  /// Join code players type in (e.g. `7FSK9`).
  final String code;
  final String title;
  final String description;
  final GameMode mode;
  final GameStatus status;
  final DateTime startsAt;

  /// Display label, e.g. `Asia/Kolkata (IST)`.
  final String timeZone;
  final int questionDurationSeconds;
  final bool openRegistration;
  final DateTime? registrationOpens;
  final DateTime? registrationCloses;
  final int players;
  final int maxPlayers;
  final List<GameQuestion> questions;
  final List<GameParticipant> participants;

  GameDetails copyWith({
    String? title,
    String? description,
    DateTime? startsAt,
    String? timeZone,
    int? questionDurationSeconds,
    bool? openRegistration,
    DateTime? registrationOpens,
    DateTime? registrationCloses,
    bool clearRegistration = false,
  }) => GameDetails(
    id: id,
    code: code,
    title: title ?? this.title,
    description: description ?? this.description,
    mode: mode,
    status: status,
    startsAt: startsAt ?? this.startsAt,
    timeZone: timeZone ?? this.timeZone,
    questionDurationSeconds:
        questionDurationSeconds ?? this.questionDurationSeconds,
    openRegistration: openRegistration ?? this.openRegistration,
    registrationOpens: clearRegistration
        ? null
        : (registrationOpens ?? this.registrationOpens),
    registrationCloses: clearRegistration
        ? null
        : (registrationCloses ?? this.registrationCloses),
    players: players,
    maxPlayers: maxPlayers,
    questions: questions,
    participants: participants,
  );
}

enum _Menu { copyCode, duplicate, delete }

/// Buzzer – Game Details screen (host).
///
/// • Tabs: Overview (details + inline editing) · Questions · Participants.
/// • Edit Game turns the details into a form; Save / Cancel bar appears.
///   Only draft and scheduled games can be edited. Game mode is locked.
/// • Uses `Theme.of(context).colorScheme` for everything → light/dark works.
///   Only the "Live / correct" green isn't in a Material ColorScheme: pass
///   [successColor] / [onSuccessColor] from your AppColors (fallback provided).
/// • Requires Flutter 3.27+ (`Color.withValues`, `PopScope.onPopInvokedWithResult`).
class GameDetailsScreen extends StatefulWidget {
  const GameDetailsScreen({
    super.key,
    required this.game,
    this.onSave,
    this.onStartGame,
    this.onManageLive,
    this.onViewResults,
    this.onUploadQuestions,
    this.onDuplicate,
    this.onDelete,
    this.timeZones = const [
      'Asia/Kolkata (IST)',
      'Asia/Dubai (GST)',
      'Asia/Singapore (SGT)',
      'Asia/Tokyo (JST)',
      'Australia/Sydney (AEST)',
      'Europe/London (GMT/BST)',
      'Europe/Paris (CET)',
      'America/New_York (ET)',
      'America/Chicago (CT)',
      'America/Los_Angeles (PT)',
      'UTC',
    ],
    this.durations = const [10, 15, 20, 30, 45, 60, 90, 120],
    this.successColor = const Color(0xFF16A34A),
    this.onSuccessColor = Colors.white,
  });

  final GameDetails game;

  /// Save edited details to your backend. Throw to show an error.
  final Future<void> Function(GameDetails updated)? onSave;

  final ValueChanged<GameDetails>? onStartGame;
  final ValueChanged<GameDetails>? onManageLive;
  final ValueChanged<GameDetails>? onViewResults;

  /// Open your PDF picker + upload (AI builds the questions).
  final VoidCallback? onUploadQuestions;

  final VoidCallback? onDuplicate;
  final Future<void> Function()? onDelete;

  final List<String> timeZones;
  final List<int> durations;
  final Color successColor;
  final Color onSuccessColor;

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  late final AnimationController _entrance;
  late final AnimationController _float;

  late final Animation<double> _headerAnim;
  late final Animation<double> _infoAnim;
  late final Animation<double> _codeAnim;
  late final Animation<double> _actionsAnim;
  late final Animation<double> _detailsAnim;
  late final Animation<double> _navAnim;

  late GameDetails _game;
  int _tab = 0;

  // Edit state
  bool _editing = false;
  bool _saving = false;
  bool _attempted = false;
  DateTime? _date;
  TimeOfDay? _time;
  String _timeZone = '';
  int _duration = 30;
  bool _openReg = true;
  DateTime? _opens;
  DateTime? _closes;

  bool _copied = false;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _game = widget.game;

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    Animation<double> stagger(double b, double e) => CurvedAnimation(
      parent: _entrance,
      curve: Interval(b, e, curve: Curves.easeOutCubic),
    );
    _headerAnim = stagger(0.0, 0.3);
    _infoAnim = stagger(0.15, 0.5);
    _codeAnim = stagger(0.25, 0.6);
    _actionsAnim = stagger(0.35, 0.7);
    _detailsAnim = stagger(0.45, 0.85);
    _navAnim = stagger(0.6, 1.0);
  }

  @override
  void didUpdateWidget(covariant GameDetailsScreen old) {
    super.didUpdateWidget(old);
    if (widget.game != old.game && !_editing) _game = widget.game;
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────── Helpers ─────────────────────────

  bool get _canEdit =>
      _game.status == GameStatus.draft || _game.status == GameStatus.scheduled;

  String _fmtDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

  String _fmtTime(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final mm = d.minute.toString().padLeft(2, '0');
    return '$h12:$mm ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  String _fmtDateTime(DateTime d) => '${_fmtDate(d)} • ${_fmtTime(d)}';

  String _fmtShort(DateTime d) =>
      '${_months[d.month - 1]} ${d.day}, ${_fmtTime(d)}';

  String _fmtDuration(int s) {
    if (s >= 60 && s % 60 == 0) {
      final m = s ~/ 60;
      return m == 1 ? '1 minute' : '$m minutes';
    }
    return '$s seconds';
  }

  String _abbr(String tz) {
    final m = RegExp(r'\(([^)]+)\)').firstMatch(tz);
    return m?.group(1) ?? tz;
  }

  DateTime? get _startsAt => (_date != null && _time != null)
      ? DateTime(
          _date!.year,
          _date!.month,
          _date!.day,
          _time!.hour,
          _time!.minute,
        )
      : null;

  bool get _dirty {
    if (!_editing) return false;
    return _titleCtrl.text.trim() != _game.title ||
        _descCtrl.text.trim() != _game.description ||
        _startsAt != _game.startsAt ||
        _timeZone != _game.timeZone ||
        _duration != _game.questionDurationSeconds ||
        _openReg != _game.openRegistration ||
        (_openReg &&
            (_opens != _game.registrationOpens ||
                _closes != _game.registrationCloses));
  }

  String? get _dateError =>
      _attempted && _date == null ? 'Select a date' : null;

  String? get _timeError {
    if (!_attempted) return null;
    if (_time == null) return 'Select a time';
    final s = _startsAt;
    if (s != null && !s.isAfter(DateTime.now())) return 'Pick a future time';
    return null;
  }

  String? get _regError {
    if (!_openReg) return null;
    final o = _opens, c = _closes, s = _startsAt;
    if (o == null || c == null) {
      return 'Set when registration opens and closes.';
    }
    if (!c.isAfter(o)) return 'Registration must close after it opens.';
    if (s != null && c.isAfter(s)) {
      return 'Registration must close before the game starts.';
    }
    return null;
  }

  void _toast(String message, {bool success = false, bool error = false}) {
    final cs = Theme.of(context).colorScheme;
    final bg = success
        ? widget.successColor
        : error
        ? cs.errorContainer
        : cs.inverseSurface;
    final fg = success
        ? widget.onSuccessColor
        : error
        ? cs.onErrorContainer
        : cs.onInverseSurface;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              Icon(
                success
                    ? Icons.check_circle_rounded
                    : error
                    ? Icons.error_outline_rounded
                    : Icons.info_outline_rounded,
                color: fg,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message, style: TextStyle(color: fg)),
              ),
            ],
          ),
        ),
      );
  }

  // ───────────────────────── Actions ─────────────────────────

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: _game.code));
    HapticFeedback.selectionClick();
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Future<void> _confirmStart() async {
    if (_game.questions.isEmpty) {
      HapticFeedback.mediumImpact();
      _toast('Add questions before starting the game.', error: true);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Icon(
          Icons.play_circle_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 36,
        ),
        title: const Text('Start game now?'),
        content: Text(
          'Players in the lobby will begin "${_game.title}" right away.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );
    if (ok == true) widget.onStartGame?.call(_game);
  }

  Future<void> _confirmDelete() async {
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Icon(Icons.delete_outline_rounded, color: cs.error, size: 36),
        title: const Text('Delete this game?'),
        content: const Text(
          'The game, its questions and registrations will be removed. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await widget.onDelete?.call();
    } catch (_) {
      if (mounted) _toast('Could not delete the game.', error: true);
    }
  }

  void _beginEdit() {
    if (!_canEdit) {
      HapticFeedback.mediumImpact();
      _toast(
        _game.status == GameStatus.live
            ? "Live games can't be edited."
            : "Completed games can't be edited.",
      );
      return;
    }
    HapticFeedback.selectionClick();
    _titleCtrl.text = _game.title;
    _descCtrl.text = _game.description;
    _date = _game.startsAt;
    _time = TimeOfDay.fromDateTime(_game.startsAt);
    _timeZone = _game.timeZone;
    _duration = _game.questionDurationSeconds;
    _openReg = _game.openRegistration;
    _opens = _game.registrationOpens;
    _closes = _game.registrationCloses;
    setState(() {
      _attempted = false;
      _editing = true;
      _tab = 0;
    });
  }

  Future<void> _cancelEdit() async {
    if (_dirty) {
      final cs = Theme.of(context).colorScheme;
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Discard changes?'),
          content: const Text('Your edits to this game will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep editing'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: cs.error),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (discard != true || !mounted) return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _editing = false);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _attempted = true);

    final formOk = _formKey.currentState?.validate() ?? false;
    final pickersOk = _dateError == null && _timeError == null;
    if (!(formOk && pickersOk && _regError == null)) {
      HapticFeedback.mediumImpact();
      _toast('Please fix the highlighted fields.', error: true);
      return;
    }
    if (!_dirty) {
      setState(() => _editing = false);
      return;
    }

    final updated = _game.copyWith(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      startsAt: _startsAt,
      timeZone: _timeZone,
      questionDurationSeconds: _duration,
      openRegistration: _openReg,
      registrationOpens: _opens,
      registrationCloses: _closes,
      clearRegistration: !_openReg,
    );

    setState(() => _saving = true);
    try {
      await widget.onSave?.call(updated);
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() {
        _game = updated;
        _editing = false;
      });
      _toast('Game updated.', success: true);
    } catch (_) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      _toast('Could not save your changes. Please try again.', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ───────────────────────── Pickers ─────────────────────────

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final initial = _date ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null && mounted) setState(() => _time = picked);
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final date = await showDatePicker(
      context: context,
      initialDate: initial != null && !initial.isBefore(first) ? initial : now,
      firstDate: first,
      lastDate: _startsAt ?? now.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? now),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<T?> _pickOption<T>({
    required String title,
    required List<T> options,
    required T selected,
    required String Function(T) labelOf,
  }) {
    final cs = Theme.of(context).colorScheme;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final maxH = MediaQuery.of(context).size.height * 0.7;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final o in options)
                          ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            title: Text(labelOf(o)),
                            trailing: o == selected
                                ? Icon(Icons.check_rounded, color: cs.primary)
                                : null,
                            onTap: () => Navigator.pop(context, o),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────── UI ─────────────────────────

  InputDecoration _dec(
    BuildContext context, {
    required String label,
    String? hint,
    IconData? icon,
    Widget? suffix,
    String? errorText,
  }) {
    final cs = Theme.of(context).colorScheme;
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.35)),
      errorText: errorText,
      prefixIcon: icon == null ? null : Icon(icon, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: cs.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: border(cs.outlineVariant),
      enabledBorder: border(cs.outlineVariant),
      focusedBorder: border(cs.primary, 1.8),
      errorBorder: border(cs.error),
      focusedErrorBorder: border(cs.error, 1.8),
    );
  }

  Widget _tapField({
    required String label,
    required String? value,
    required IconData icon,
    required VoidCallback onTap,
    IconData suffix = Icons.expand_more_rounded,
    String? errorText,
  }) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _saving ? null : onTap,
      child: InputDecorator(
        isEmpty: value == null,
        decoration: _dec(
          context,
          label: label,
          icon: icon,
          errorText: errorText,
          suffix: Icon(suffix, size: 20),
        ),
        child: Text(
          value ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBuzzer = _game.mode == GameMode.buzzer;

    return PopScope(
      canPop: !(_editing && _dirty),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancelEdit();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(statusBarColor: Colors.transparent),
        child: Scaffold(
          backgroundColor: cs.surface,
          bottomNavigationBar: _Reveal(
            animation: _navAnim,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: _editing
                  ? _SaveBar(
                      key: const ValueKey('save'),
                      saving: _saving,
                      onCancel: _saving ? null : _cancelEdit,
                      onSave: _saving ? null : _save,
                    )
                  : DecoratedBox(
                      key: const ValueKey('nav'),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      child: NavigationBar(
                        selectedIndex: _tab,
                        backgroundColor: cs.surfaceContainerLowest,
                        indicatorColor: cs.primaryContainer,
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        onDestinationSelected: (i) {
                          HapticFeedback.selectionClick();
                          setState(() => _tab = i);
                        },
                        destinations: const [
                          NavigationDestination(
                            icon: Icon(Icons.check_circle_outline_rounded),
                            selectedIcon: Icon(Icons.check_circle_rounded),
                            label: 'Overview',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.quiz_outlined),
                            selectedIcon: Icon(Icons.quiz_rounded),
                            label: 'Questions',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.groups_outlined),
                            selectedIcon: Icon(Icons.groups_rounded),
                            label: 'Participants',
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          body: Stack(
            children: [
              _Background(animation: _float),
              SafeArea(
                bottom: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        // Header: back + menu, icon + title + badges
                        _Reveal(
                          animation: _headerAnim,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      tooltip: 'Back',
                                      onPressed: () =>
                                          Navigator.maybePop(context),
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                      ),
                                      color: cs.onSurface,
                                    ),
                                    const Spacer(),
                                    PopupMenuButton<_Menu>(
                                      tooltip: 'More',
                                      icon: Icon(
                                        Icons.more_vert_rounded,
                                        color: cs.onSurface,
                                      ),
                                      color: cs.surfaceContainerLowest,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      onSelected: (m) {
                                        switch (m) {
                                          case _Menu.copyCode:
                                            _copyCode();
                                            _toast('Game code copied.');
                                          case _Menu.duplicate:
                                            widget.onDuplicate?.call();
                                          case _Menu.delete:
                                            _confirmDelete();
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: _Menu.copyCode,
                                          child: _MenuRow(
                                            icon: Icons.copy_rounded,
                                            label: 'Copy game code',
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: _Menu.duplicate,
                                          child: _MenuRow(
                                            icon: Icons.content_copy_rounded,
                                            label: 'Duplicate game',
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: _Menu.delete,
                                          child: _MenuRow(
                                            icon: Icons.delete_outline_rounded,
                                            label: 'Delete game',
                                            color: cs.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    0,
                                    12,
                                    4,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 58,
                                        height: 58,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [cs.primary, cs.tertiary],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: cs.primary.withValues(
                                                alpha: 0.3,
                                              ),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          isBuzzer
                                              ? Icons.bolt_rounded
                                              : Icons.sports_esports_rounded,
                                          color: cs.onPrimary,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AnimatedSwitcher(
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              child: Text(
                                                _game.title,
                                                key: ValueKey(_game.title),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: text.titleLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: cs.onSurface,
                                                      height: 1.2,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 6,
                                              children: [
                                                _Pill(
                                                  icon: isBuzzer
                                                      ? Icons.bolt_rounded
                                                      : Icons
                                                            .sports_esports_rounded,
                                                  label: isBuzzer
                                                      ? 'Buzzer Game'
                                                      : 'Quiz Game',
                                                ),
                                                _StatusBadge(
                                                  status: _game.status,
                                                  pulse: _float,
                                                  successColor:
                                                      widget.successColor,
                                                  onSuccessColor:
                                                      widget.onSuccessColor,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),

                        // Tab content
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            transitionBuilder: (child, anim) => FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.04, 0),
                                  end: Offset.zero,
                                ).animate(anim),
                                child: child,
                              ),
                            ),
                            child: switch (_tab) {
                              0 => _overview(context),
                              1 => _QuestionsTab(
                                key: const ValueKey('q'),
                                questions: _game.questions,
                                successColor: widget.successColor,
                                onUpload: widget.onUploadQuestions,
                              ),
                              _ => _ParticipantsTab(
                                key: const ValueKey('p'),
                                participants: _game.participants,
                                players: _game.players,
                                maxPlayers: _game.maxPlayers,
                                fmt: _fmtShort,
                              ),
                            },
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

  // ───────────────────────── Overview tab ─────────────────────────

  Widget _overview(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return ListView(
      key: const ValueKey('overview'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (c, a) => FadeTransition(
            opacity: a,
            child: SizeTransition(sizeFactor: a, axisAlignment: -1, child: c),
          ),
          child: _editing
              ? Padding(
                  key: const ValueKey('editBanner'),
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 18, color: cs.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Editing game details',
                            style: text.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('noBanner')),
        ),

        if (!_editing) ...[
          // Info tiles
          _Reveal(
            animation: _infoAnim,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: _InfoTile(
                        icon: Icons.calendar_month_rounded,
                        label: 'Date & time',
                        value:
                            '${_fmtDate(_game.startsAt)}\n${_fmtTime(_game.startsAt)} (${_abbr(_game.timeZone)})',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: _InfoTile(
                        icon: Icons.quiz_outlined,
                        label: 'Questions',
                        value: '${_game.questions.length}',
                        numeric: _game.questions.length,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: _InfoTile(
                        icon: Icons.how_to_reg_rounded,
                        label: 'Registered',
                        value: '${_game.players}/${_game.maxPlayers}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: _InfoTile(
                        icon: Icons.timer_outlined,
                        label: 'Per question',
                        value: '${_game.questionDurationSeconds}s',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Game code
          _Reveal(
            animation: _codeAnim,
            child: _CodeCard(
              code: _game.code,
              copied: _copied,
              onCopy: _copyCode,
            ),
          ),
          const SizedBox(height: 16),

          // Actions
          _Reveal(
            animation: _actionsAnim,
            child: _ActionRow(
              status: _game.status,
              onPrimary: switch (_game.status) {
                GameStatus.live => () => widget.onManageLive?.call(_game),
                GameStatus.completed => () => widget.onViewResults?.call(_game),
                _ => _confirmStart,
              },
              onEdit: _beginEdit,
              editEnabled: _canEdit,
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Details (read-only or form)
        _Reveal(
          animation: _detailsAnim,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (c, a) => FadeTransition(
              opacity: a,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1).animate(a),
                child: c,
              ),
            ),
            child: _editing ? _editForm(context) : _detailsCard(context),
          ),
        ),
      ],
    );
  }

  Widget _detailsCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final registration = !_game.openRegistration
        ? 'Registration is closed'
        : (_game.registrationOpens != null && _game.registrationCloses != null)
        ? '${_fmtShort(_game.registrationOpens!)} – ${_fmtShort(_game.registrationCloses!)}'
        : 'Open';

    return Container(
      key: const ValueKey('details'),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: _cardDecoration(cs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              'Game Details',
              style: text.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ),
          _DetailRow(
            icon: _game.mode == GameMode.buzzer
                ? Icons.bolt_rounded
                : Icons.sports_esports_rounded,
            label: 'Mode',
            value: _game.mode == GameMode.buzzer ? 'Buzzer Game' : 'Quiz Game',
          ),
          const _RowDivider(),
          _DetailRow(
            icon: Icons.notes_rounded,
            label: 'Description',
            value: _game.description.isEmpty
                ? 'No description'
                : _game.description,
            muted: _game.description.isEmpty,
          ),
          const _RowDivider(),
          _DetailRow(
            icon: Icons.public_rounded,
            label: 'Time zone',
            value: _game.timeZone,
          ),
          const _RowDivider(),
          _DetailRow(
            icon: Icons.timer_outlined,
            label: 'Question duration',
            value: _fmtDuration(_game.questionDurationSeconds),
          ),
          const _RowDivider(),
          _DetailRow(
            icon: Icons.app_registration_rounded,
            label: 'Registration',
            value: registration,
          ),
        ],
      ),
    );
  }

  Widget _editForm(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      key: const ValueKey('form'),
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(cs),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Locked mode
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_game.mode == GameMode.buzzer ? 'Buzzer Game' : 'Quiz Game'} — the mode can\'t be changed after creation.',
                      style: text.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleCtrl,
              enabled: !_saving,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              maxLength: 60,
              onChanged: (_) => setState(() {}),
              decoration: _dec(
                context,
                label: 'Game title *',
                icon: Icons.title_rounded,
              ).copyWith(counterText: ''),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'Please enter a game title';
                if (t.length < 3) return 'Title is too short';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descCtrl,
              enabled: !_saving,
              textCapitalization: TextCapitalization.sentences,
              minLines: 3,
              maxLines: 4,
              maxLength: 300,
              onChanged: (_) => setState(() {}),
              decoration: _dec(
                context,
                label: 'Description (optional)',
              ).copyWith(alignLabelWithHint: true),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _tapField(
                    label: 'Date *',
                    icon: Icons.calendar_today_rounded,
                    value: _date == null ? null : _fmtDate(_date!),
                    suffix: Icons.event_available_rounded,
                    errorText: _dateError,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _tapField(
                    label: 'Start time *',
                    icon: Icons.schedule_rounded,
                    value: _time == null
                        ? null
                        : _fmtTime(
                            DateTime(2000, 1, 1, _time!.hour, _time!.minute),
                          ),
                    suffix: Icons.access_time_rounded,
                    errorText: _timeError,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _tapField(
              label: 'Time zone',
              icon: Icons.public_rounded,
              value: _timeZone,
              onTap: () async {
                final v = await _pickOption<String>(
                  title: 'Time zone',
                  options: widget.timeZones.contains(_timeZone)
                      ? widget.timeZones
                      : [_timeZone, ...widget.timeZones],
                  selected: _timeZone,
                  labelOf: (s) => s,
                );
                if (v != null && mounted) setState(() => _timeZone = v);
              },
            ),
            const SizedBox(height: 14),
            _tapField(
              label: 'Question duration *',
              icon: Icons.timer_outlined,
              value: _fmtDuration(_duration),
              onTap: () async {
                final v = await _pickOption<int>(
                  title: 'Question duration',
                  options:
                      widget.durations.contains(_duration)
                            ? widget.durations
                            : [...widget.durations, _duration]
                        ..sort(),
                  selected: _duration,
                  labelOf: _fmtDuration,
                );
                if (v != null && mounted) setState(() => _duration = v);
              },
            ),
            const SizedBox(height: 18),

            // Registration
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Open registration',
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Players can register during a set window.',
                        style: text.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _openReg,
                  onChanged: _saving
                      ? null
                      : (v) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _openReg = v;
                            if (v) {
                              final n = DateTime.now();
                              _opens ??= DateTime(
                                n.year,
                                n.month,
                                n.day,
                                n.hour,
                                n.minute,
                              );
                              _closes ??= _startsAt?.subtract(
                                const Duration(hours: 1),
                              );
                            }
                          });
                        },
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: !_openReg
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Column(
                        children: [
                          _tapField(
                            label: 'Registration opens',
                            icon: Icons.event_available_outlined,
                            value: _opens == null
                                ? null
                                : _fmtDateTime(_opens!),
                            suffix: Icons.calendar_month_rounded,
                            onTap: () async {
                              final v = await _pickDateTime(_opens);
                              if (v != null && mounted) {
                                setState(() => _opens = v);
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                          _tapField(
                            label: 'Registration closes',
                            icon: Icons.event_busy_outlined,
                            value: _closes == null
                                ? null
                                : _fmtDateTime(_closes!),
                            suffix: Icons.calendar_month_rounded,
                            onTap: () async {
                              final v = await _pickDateTime(_closes);
                              if (v != null && mounted) {
                                setState(() => _closes = v);
                              }
                            },
                          ),
                          if (_attempted && _regError != null) ...[
                            const SizedBox(height: 12),
                            _ErrorNote(message: _regError!),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(ColorScheme cs) => BoxDecoration(
    color: cs.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
    boxShadow: [
      BoxShadow(
        color: cs.shadow.withValues(alpha: 0.06),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

// ───────────────────────── Overview widgets ─────────────────────────

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.numeric,
  });

  final IconData icon;
  final String label;
  final String value;

  /// When set, the value counts up from 0.
  final int? numeric;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final style = text.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: cs.onSurface,
      height: 1.3,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primaryContainer,
            ),
            child: Icon(icon, size: 18, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: text.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                if (numeric != null)
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: numeric!),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => Text('$v', style: style),
                  )
                else
                  Text(value, style: style),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({
    required this.code,
    required this.copied,
    required this.onCopy,
  });

  final String code;
  final bool copied;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer.withValues(alpha: 0.8),
            cs.tertiaryContainer.withValues(alpha: 0.8),
          ],
        ),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.pin_outlined, color: cs.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game code',
                  style: text.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 22,
                    letterSpacing: 5,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onCopy,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Icon(
                copied ? Icons.check_rounded : Icons.copy_rounded,
                key: ValueKey(copied),
                size: 18,
              ),
            ),
            label: Text(copied ? 'Copied' : 'Copy'),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.status,
    required this.onPrimary,
    required this.onEdit,
    required this.editEnabled,
  });

  final GameStatus status;
  final VoidCallback onPrimary;
  final VoidCallback onEdit;
  final bool editEnabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (label, icon) = switch (status) {
      GameStatus.live => ('Manage Live', Icons.sensors_rounded),
      GameStatus.completed => ('View Results', Icons.leaderboard_rounded),
      _ => ('Start Game', Icons.play_arrow_rounded),
    };

    return Row(
      children: [
        Expanded(
          child: _GradientButton(
            label: label,
            icon: icon,
            onPressed: onPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: editEnabled ? 1 : 0.5,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onEdit,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.primary, width: 1.6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_outlined, color: cs.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Edit Game',
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
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
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.muted = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: text.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: muted
                        ? cs.onSurface.withValues(alpha: 0.5)
                        : cs.onSurface,
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

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
  );
}

class _ErrorNote extends StatelessWidget {
  const _ErrorNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: cs.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.5, height: 1.4, color: cs.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    super.key,
    required this.saving,
    required this.onCancel,
    required this.onSave,
  });

  final bool saving;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: cs.outline),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: _GradientButton(
                  label: 'Save Changes',
                  icon: Icons.check_rounded,
                  loading: saving,
                  onPressed: onSave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Questions tab ─────────────────────────

class _QuestionsTab extends StatelessWidget {
  const _QuestionsTab({
    super.key,
    required this.questions,
    required this.successColor,
    this.onUpload,
  });

  final List<GameQuestion> questions;
  final Color successColor;
  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (questions.isEmpty) {
      return _EmptyState(
        icon: Icons.upload_file_rounded,
        title: 'No questions yet',
        subtitle: 'Upload a PDF with questions and answers and we\'ll build them for you.',
        actionLabel: 'Upload PDF',
        onAction: onUpload,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      itemCount: questions.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(
                  '${questions.length} questions',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                if (onUpload != null)
                  TextButton.icon(
                    onPressed: onUpload,
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: const Text('Replace PDF'),
                  ),
              ],
            ),
          );
        }
        final q = questions[i - 1];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (i.clamp(0, 8)) * 70),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, 14 * (1 - v)),
              child: child,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _QuestionTile(
              number: i,
              question: q,
              successColor: successColor,
            ),
          ),
        );
      },
    );
  }
}

class _QuestionTile extends StatefulWidget {
  const _QuestionTile({
    required this.number,
    required this.question,
    required this.successColor,
  });

  final int number;
  final GameQuestion question;
  final Color successColor;

  @override
  State<_QuestionTile> createState() => _QuestionTileState();
}

class _QuestionTileState extends State<_QuestionTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final q = widget.question;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _open = !_open);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _open
                ? cs.primary.withValues(alpha: 0.6)
                : cs.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: cs.primaryContainer,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${widget.number}',
                      style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      q.text,
                      maxLines: _open ? null : 2,
                      overflow: _open ? null : TextOverflow.ellipsis,
                      style: text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        height: 1.35,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 250),
                    turns: _open ? 0.5 : 0,
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              if (_open) ...[
                const SizedBox(height: 12),
                for (var i = 0; i < q.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _OptionRow(
                      letter: String.fromCharCode(65 + i),
                      label: q.options[i],
                      correct: q.correctIndex == i,
                      successColor: widget.successColor,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.letter,
    required this.label,
    required this.correct,
    required this.successColor,
  });

  final String letter;
  final String label;
  final bool correct;
  final Color successColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = correct ? successColor : cs.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: correct
            ? successColor.withValues(alpha: 0.12)
            : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: correct
              ? successColor
              : cs.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Text(
            letter,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: correct
                  ? successColor
                  : cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: accent,
                fontWeight: correct ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          if (correct)
            Icon(Icons.check_circle_rounded, size: 18, color: successColor),
        ],
      ),
    );
  }
}

// ───────────────────────── Participants tab ─────────────────────────

class _ParticipantsTab extends StatelessWidget {
  const _ParticipantsTab({
    super.key,
    required this.participants,
    required this.players,
    required this.maxPlayers,
    required this.fmt,
  });

  final List<GameParticipant> participants;
  final int players;
  final int maxPlayers;
  final String Function(DateTime) fmt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final bg = [
      (cs.primaryContainer, cs.onPrimaryContainer),
      (cs.secondaryContainer, cs.onSecondaryContainer),
      (cs.tertiaryContainer, cs.onTertiaryContainer),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      itemCount: participants.isEmpty ? 2 : participants.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          final ratio = maxPlayers == 0 ? 0.0 : players / maxPlayers;
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Registered players',
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$players/$maxPlayers',
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 8,
                      color: cs.primary,
                      backgroundColor: cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (participants.isEmpty) {
          return const _EmptyState(
            icon: Icons.groups_outlined,
            title: 'No participants yet',
            subtitle: 'Share the game code so players can join.',
            shrink: true,
          );
        }

        final p = participants[i - 1];
        final colors = bg[(i - 1) % bg.length];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (i.clamp(0, 10)) * 60),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, 12 * (1 - v)),
              child: child,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colors.$1,
                  backgroundImage: p.avatarUrl != null
                      ? NetworkImage(p.avatarUrl!)
                      : null,
                  child: p.avatarUrl == null
                      ? Text(
                          p.name.isEmpty ? '?' : p.name[0].toUpperCase(),
                          style: TextStyle(
                            color: colors.$2,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      if (p.registeredAt != null)
                        Text(
                          'Registered ${fmt(p.registeredAt!)}',
                          style: text.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                    ],
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.shrink = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool shrink;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final content = Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primaryContainer,
            ),
            child: Icon(icon, size: 34, color: cs.onPrimaryContainer),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: onAction,
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );

    return shrink ? content : Center(child: content);
  }
}

// ───────────────────────── Shared small widgets ─────────────────────────

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Icon(icon, size: 20, color: c),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: c, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onPrimaryContainer),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: cs.onPrimaryContainer,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.pulse,
    required this.successColor,
    required this.onSuccessColor,
  });

  final GameStatus status;
  final Animation<double> pulse;
  final Color successColor;
  final Color onSuccessColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (bg, fg, label) = switch (status) {
      GameStatus.live => (successColor, onSuccessColor, 'Live'),
      GameStatus.scheduled => (
        cs.secondaryContainer,
        cs.onSecondaryContainer,
        'Scheduled',
      ),
      GameStatus.draft => (
        cs.surfaceContainerHigh,
        cs.onSurface.withValues(alpha: 0.7),
        'Draft',
      ),
      GameStatus.completed => (
        cs.tertiaryContainer,
        cs.onTertiaryContainer,
        'Completed',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == GameStatus.live) ...[
            AnimatedBuilder(
              animation: pulse,
              builder: (context, _) => Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fg.withValues(alpha: 0.4 + 0.6 * pulse.value),
                ),
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
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
    this.loading = false,
  });

  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: loading ? 0.1 : 0.28),
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
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (c, a) => FadeTransition(
                    opacity: a,
                    child: ScaleTransition(scale: a, child: c),
                  ),
                  child: loading
                      ? SizedBox(
                          key: const ValueKey('loader'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: cs.onPrimary,
                          ),
                        )
                      : Row(
                          key: ValueKey(label),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: cs.onPrimary, size: 21),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: TextStyle(
                                color: cs.onPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
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
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
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
                top: -90 + 25 * t,
                right: -100 + 20 * t,
                child: blob(cs.primaryContainer, 320),
              ),
              Positioned(
                bottom: -120 + 25 * (1 - t),
                left: -110 + 25 * t,
                child: blob(cs.tertiaryContainer, 300),
              ),
            ],
          );
        },
      ),
    );
  }
}

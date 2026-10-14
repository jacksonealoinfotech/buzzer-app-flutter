import 'dart:math' as math;
import 'dart:typed_data';

import 'package:buzzer_app/features/hostFlow/host_dashboard/presenation/screen/host_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Reuses the GameMode enum (buzzer / quiz) from the host dashboard file.

/// A PDF chosen by the host (questions + answers).
class PdfAttachment {
  const PdfAttachment({
    required this.name,
    required this.sizeBytes,
    this.path,
    this.bytes,
  });

  final String name;
  final int sizeBytes;
  final String? path;
  final Uint8List? bytes;
}

/// Everything the backend needs to create the game.
class CreateGameData {
  const CreateGameData({
    required this.mode,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.timeZone,
    required this.questionDurationSeconds,
    required this.openRegistration,
    this.registrationOpens,
    this.registrationCloses,
    this.pdf,
  });

  final GameMode mode;
  final String title;
  final String description;

  /// Local date + time chosen by the host, interpreted in [timeZone].
  final DateTime startsAt;

  /// IANA id, e.g. `Asia/Kolkata`.
  final String timeZone;
  final int questionDurationSeconds;
  final bool openRegistration;
  final DateTime? registrationOpens;
  final DateTime? registrationCloses;

  /// Send this to your backend so the AI can extract questions & answers.
  final PdfAttachment? pdf;
}

/// Buzzer – Create Game screen (single page).
///
/// • Mode tab (Buzzer / Quiz) + game details + registration + PDF upload.
/// • Uses ONLY `Theme.of(context).colorScheme` → light/dark works automatically.
/// • No file-picker dependency inside: pass [onPickPdf] (example in the docs).
/// • Requires Flutter 3.27+ (`Color.withValues`, `PopScope.onPopInvokedWithResult`).
class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({
    super.key,
    required this.onPickPdf,
    this.onCreate,
    this.requirePdf = false,
    this.maxPdfSizeMb = 20,
    this.initialMode = GameMode.buzzer,
    this.initialTimeZone = 'Asia/Kolkata (IST)',
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
    this.initialDuration = 30,
  });

  /// Open your file picker and return the chosen PDF (or null if cancelled).
  final Future<PdfAttachment?> Function() onPickPdf;

  /// Call your API here. Throw an exception to show an error.
  final Future<void> Function(CreateGameData data)? onCreate;

  final bool requirePdf;
  final int maxPdfSizeMb;
  final GameMode initialMode;
  final String initialTimeZone;
  final List<String> timeZones;
  final List<int> durations;
  final int initialDuration;

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _detailsKey = GlobalKey();
  final _regKey = GlobalKey();
  final _pdfKey = GlobalKey();
  final _scroll = ScrollController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  late final AnimationController _entrance;
  late final AnimationController _float;
  late final AnimationController _shake;

  late final Animation<double> _headerAnim;
  late final Animation<double> _modeAnim;
  late final Animation<double> _detailsAnim;
  late final Animation<double> _regAnim;
  late final Animation<double> _pdfAnim;
  late final Animation<double> _buttonAnim;

  late GameMode _mode;
  late String _timeZone;
  late int _duration;

  DateTime? _date;
  TimeOfDay? _time;

  bool _openReg = true;
  DateTime? _opens;
  DateTime? _closes;
  bool _opensManual = false;
  bool _closesManual = false;

  PdfAttachment? _pdf;
  bool _picking = false;
  bool _loading = false;
  bool _attempted = false;
  bool _saved = false;

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
    _mode = widget.initialMode;
    _timeZone = widget.initialTimeZone;
    _duration = widget.initialDuration;
    _syncRegistration();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
    _headerAnim = stagger(0.0, 0.3);
    _modeAnim = stagger(0.08, 0.42);
    _detailsAnim = stagger(0.22, 0.58);
    _regAnim = stagger(0.36, 0.72);
    _pdfAnim = stagger(0.50, 0.86);
    _buttonAnim = stagger(0.64, 1.0);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    _shake.dispose();
    _scroll.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────── Helpers ─────────────────────────

  bool get _dirty =>
      !_saved &&
      (_titleCtrl.text.trim().isNotEmpty ||
          _descCtrl.text.trim().isNotEmpty ||
          _pdf != null ||
          _date != null ||
          _time != null);

  DateTime? get _startsAt => (_date != null && _time != null)
      ? DateTime(
          _date!.year,
          _date!.month,
          _date!.day,
          _time!.hour,
          _time!.minute,
        )
      : null;

  String _fmtDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

  String _fmtTime(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final mm = d.minute.toString().padLeft(2, '0');
    return '$h12:$mm ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  String _fmtDateTime(DateTime d) => '${_fmtDate(d)} • ${_fmtTime(d)}';

  String _fmtDuration(int s) {
    if (s >= 60 && s % 60 == 0) {
      final m = s ~/ 60;
      return m == 1 ? '1 minute' : '$m minutes';
    }
    return '$s seconds';
  }

  String _fmtBytes(int b) {
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Auto-fill registration window until the host edits it manually:
  /// opens = now, closes = 1 hour before the game starts.
  void _syncRegistration() {
    final s = _startsAt;
    if (!_closesManual && s != null) {
      _closes = s.subtract(const Duration(hours: 1));
    }
    if (!_opensManual) {
      final n = DateTime.now();
      _opens = DateTime(n.year, n.month, n.day, n.hour, n.minute);
    }
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

  String? get _registrationError {
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

  // ───────────────────────── Pickers ─────────────────────────

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null && mounted) {
      setState(() {
        _date = picked;
        _syncRegistration();
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          _time ??
          TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1))),
    );
    if (picked != null && mounted) {
      setState(() {
        _time = picked;
        _syncRegistration();
      });
    }
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

  Future<void> _pickPdf() async {
    if (_picking || _loading) return;
    setState(() => _picking = true);
    try {
      final f = await widget.onPickPdf();
      if (f == null || !mounted) return;
      if (!f.name.toLowerCase().endsWith('.pdf')) {
        _showError('Please choose a PDF file.');
        return;
      }
      if (f.sizeBytes > widget.maxPdfSizeMb * 1024 * 1024) {
        _showError(
          'PDF is too large. Maximum size is ${widget.maxPdfSizeMb} MB.',
        );
        return;
      }
      HapticFeedback.selectionClick();
      setState(() => _pdf = f);
    } catch (_) {
      if (mounted) _showError('Could not open the file picker.');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  // ───────────────────────── Submit ─────────────────────────

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _attempted = true);

    final formOk = _formKey.currentState!.validate();
    final pickersOk =
        _dateError == null &&
        _timeError == null &&
        _date != null &&
        _time != null;
    final regOk = _registrationError == null;
    final pdfOk = !widget.requirePdf || _pdf != null;

    if (!(formOk && pickersOk && regOk && pdfOk)) {
      HapticFeedback.mediumImpact();
      _shake.forward(from: 0);
      _showError(
        !pdfOk && formOk && pickersOk && regOk
            ? 'Please upload the questions PDF.'
            : 'Please fix the highlighted fields.',
      );
      final GlobalKey target = (!formOk || !pickersOk)
          ? _detailsKey
          : (!regOk ? _regKey : _pdfKey);
      final ctx = target.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          alignment: 0.05,
        );
      }
      return;
    }

    final data = CreateGameData(
      mode: _mode,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      startsAt: _startsAt!,
      timeZone: _timeZone.split(' (').first,
      questionDurationSeconds: _duration,
      openRegistration: _openReg,
      registrationOpens: _openReg ? _opens : null,
      registrationCloses: _openReg ? _closes : null,
      pdf: _pdf,
    );

    setState(() => _loading = true);
    try {
      await (widget.onCreate ??
          (_) => Future.delayed(const Duration(milliseconds: 1500)))(data);
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() => _saved = true);
      // TODO: navigate to the game details screen
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      _shake.forward(from: 0);
      _showError('Could not create the game. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmDiscard() async {
    final cs = Theme.of(context).colorScheme;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Discard this game?'),
        content: const Text('The details you entered will be lost.'),
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
    if (discard == true && mounted) Navigator.of(context).pop();
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
      disabledBorder: border(cs.outlineVariant.withValues(alpha: 0.5)),
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
      onTap: _loading ? null : onTap,
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
    final muted = cs.onSurface.withValues(alpha: 0.6);

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Stack(
          children: [
            _Background(animation: _float),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
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
                                tooltip: 'Back',
                                onPressed: () => Navigator.maybePop(context),
                                icon: const Icon(Icons.arrow_back_rounded),
                                color: cs.onSurface,
                              ),
                              Text(
                                'Create Game',
                                style: text.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Scrollable form
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => FocusScope.of(context).unfocus(),
                          child: SingleChildScrollView(
                            controller: _scroll,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                            child: Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Mode tab
                                  _Reveal(
                                    animation: _modeAnim,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _ModeSwitcher(
                                          mode: _mode,
                                          onChanged: _loading
                                              ? null
                                              : (m) {
                                                  HapticFeedback.selectionClick();
                                                  setState(() => _mode = m);
                                                },
                                        ),
                                        const SizedBox(height: 12),
                                        AnimatedSize(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          curve: Curves.easeOut,
                                          alignment: Alignment.topCenter,
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            transitionBuilder: (c, a) =>
                                                FadeTransition(
                                                  opacity: a,
                                                  child: SlideTransition(
                                                    position: Tween<Offset>(
                                                      begin: const Offset(
                                                        0.06,
                                                        0,
                                                      ),
                                                      end: Offset.zero,
                                                    ).animate(a),
                                                    child: c,
                                                  ),
                                                ),
                                            layoutBuilder: (cur, prev) => Stack(
                                              alignment: Alignment.topLeft,
                                              children: [
                                                ...prev,
                                                if (cur != null) cur,
                                              ],
                                            ),
                                            child: _ModeInfo(
                                              key: ValueKey(_mode),
                                              mode: _mode,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Details
                                  _Reveal(
                                    animation: _detailsAnim,
                                    child: _SectionCard(
                                      key: _detailsKey,
                                      icon: Icons.edit_note_rounded,
                                      title: 'Game details',
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: _titleCtrl,
                                            enabled: !_loading,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            textInputAction:
                                                TextInputAction.next,
                                            maxLength: 60,
                                            onChanged: (_) => setState(() {}),
                                            decoration: _dec(
                                              context,
                                              label: 'Game title *',
                                              hint: 'e.g. Tech Knowledge Challenge',
                                              icon: Icons.title_rounded,
                                            ).copyWith(counterText: ''),
                                            validator: (v) {
                                              final t = v?.trim() ?? '';
                                              if (t.isEmpty) {
                                                return 'Please enter a game title';
                                              }
                                              if (t.length < 3) {
                                                return 'Title is too short';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 14),
                                          TextFormField(
                                            controller: _descCtrl,
                                            enabled: !_loading,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            minLines: 3,
                                            maxLines: 4,
                                            maxLength: 300,
                                            onChanged: (_) => setState(() {}),
                                            decoration:
                                                _dec(
                                                  context,
                                                  label:
                                                      'Description (optional)',
                                                  hint: 'A fun quiz for all tech enthusiasts.',
                                                ).copyWith(
                                                  alignLabelWithHint: true,
                                                ),
                                          ),
                                          const SizedBox(height: 14),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: _tapField(
                                                  label: 'Date *',
                                                  icon: Icons
                                                      .calendar_today_rounded,
                                                  value: _date == null
                                                      ? null
                                                      : _fmtDate(_date!),
                                                  suffix: Icons
                                                      .event_available_rounded,
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
                                                          DateTime(
                                                            2000,
                                                            1,
                                                            1,
                                                            _time!.hour,
                                                            _time!.minute,
                                                          ),
                                                        ),
                                                  suffix:
                                                      Icons.access_time_rounded,
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
                                              final v =
                                                  await _pickOption<String>(
                                                    title: 'Time zone',
                                                    options: widget.timeZones,
                                                    selected: _timeZone,
                                                    labelOf: (s) => s,
                                                  );
                                              if (v != null && mounted) {
                                                setState(() => _timeZone = v);
                                              }
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
                                                options: widget.durations,
                                                selected: _duration,
                                                labelOf: _fmtDuration,
                                              );
                                              if (v != null && mounted) {
                                                setState(() => _duration = v);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Registration
                                  _Reveal(
                                    animation: _regAnim,
                                    child: _SectionCard(
                                      key: _regKey,
                                      icon: Icons.how_to_reg_rounded,
                                      title: 'Registration',
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Open registration',
                                                      style: text.titleSmall
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: cs.onSurface,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Players can register during a set window.',
                                                      style: text.bodySmall
                                                          ?.copyWith(
                                                            color: muted,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Switch(
                                                value: _openReg,
                                                onChanged: _loading
                                                    ? null
                                                    : (v) {
                                                        HapticFeedback.selectionClick();
                                                        setState(() {
                                                          _openReg = v;
                                                          if (v) {
                                                            _syncRegistration();
                                                          }
                                                        });
                                                      },
                                              ),
                                            ],
                                          ),
                                          AnimatedSize(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeOutCubic,
                                            alignment: Alignment.topCenter,
                                            child: !_openReg
                                                ? const SizedBox(
                                                    width: double.infinity,
                                                  )
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 16,
                                                        ),
                                                    child: Column(
                                                      children: [
                                                        _tapField(
                                                          label: 'Registration opens',
                                                          icon: Icons
                                                              .event_available_outlined,
                                                          value: _opens == null
                                                              ? null
                                                              : _fmtDateTime(
                                                                  _opens!,
                                                                ),
                                                          suffix: Icons
                                                              .calendar_month_rounded,
                                                          onTap: () async {
                                                            final v =
                                                                await _pickDateTime(
                                                                  _opens,
                                                                );
                                                            if (v != null &&
                                                                mounted) {
                                                              setState(() {
                                                                _opens = v;
                                                                _opensManual =
                                                                    true;
                                                              });
                                                            }
                                                          },
                                                        ),
                                                        const SizedBox(
                                                          height: 14,
                                                        ),
                                                        _tapField(
                                                          label: 'Registration closes',
                                                          icon: Icons
                                                              .event_busy_outlined,
                                                          value: _closes == null
                                                              ? null
                                                              : _fmtDateTime(
                                                                  _closes!,
                                                                ),
                                                          suffix: Icons
                                                              .calendar_month_rounded,
                                                          onTap: () async {
                                                            final v =
                                                                await _pickDateTime(
                                                                  _closes,
                                                                );
                                                            if (v != null &&
                                                                mounted) {
                                                              setState(() {
                                                                _closes = v;
                                                                _closesManual =
                                                                    true;
                                                              });
                                                            }
                                                          },
                                                        ),
                                                        const SizedBox(
                                                          height: 12,
                                                        ),
                                                        _InfoNote(
                                                          message:
                                                              _attempted &&
                                                                  _registrationError !=
                                                                      null
                                                              ? _registrationError!
                                                              : 'Registration will close 1 hour before the game starts.',
                                                          isError:
                                                              _attempted &&
                                                              _registrationError !=
                                                                  null,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // PDF upload
                                  _Reveal(
                                    animation: _pdfAnim,
                                    child: _SectionCard(
                                      key: _pdfKey,
                                      icon: Icons.upload_file_rounded,
                                      title: widget.requirePdf
                                          ? 'Questions PDF *'
                                          : 'Questions PDF',
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            transitionBuilder: (c, a) =>
                                                FadeTransition(
                                                  opacity: a,
                                                  child: ScaleTransition(
                                                    scale: Tween<double>(
                                                      begin: 0.96,
                                                      end: 1,
                                                    ).animate(a),
                                                    child: c,
                                                  ),
                                                ),
                                            child: _pdf == null
                                                ? _PdfDropZone(
                                                    key: const ValueKey(
                                                      'empty',
                                                    ),
                                                    loading: _picking,
                                                    hasError:
                                                        _attempted &&
                                                        widget.requirePdf,
                                                    maxMb: widget.maxPdfSizeMb,
                                                    onTap: _pickPdf,
                                                  )
                                                : _PdfTile(
                                                    key: const ValueKey('file'),
                                                    name: _pdf!.name,
                                                    size: _fmtBytes(
                                                      _pdf!.sizeBytes,
                                                    ),
                                                    onReplace: _pickPdf,
                                                    onRemove: _loading
                                                        ? null
                                                        : () => setState(
                                                            () => _pdf = null,
                                                          ),
                                                  ),
                                          ),
                                          const SizedBox(height: 12),
                                          const _InfoNote(
                                            icon: Icons.auto_awesome_rounded,
                                            message: 'Upload a PDF with your questions and answers. We\'ll read it with AI and build the questions for you — you can review them after the game is created.',
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

                      // Create button
                      _Reveal(
                        animation: _buttonAnim,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          child: AnimatedBuilder(
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
                            child: _GradientButton(
                              label: 'Create Game',
                              loading: _loading,
                              onPressed: _loading ? null : _submit,
                            ),
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
    );
  }
}

// ───────────────────────── Widgets ─────────────────────────

/// Animated 2-segment tab: Buzzer Game | Quiz Game.
class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({required this.mode, required this.onChanged});

  final GameMode mode;
  final ValueChanged<GameMode>? onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget segment(GameMode m, IconData icon, String label) {
      final selected = mode == m;
      final color = selected
          ? cs.onPrimary
          : cs.onSurface.withValues(alpha: 0.7);
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onChanged == null ? null : () => onChanged!(m),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    icon,
                    key: ValueKey(selected),
                    size: 20,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            alignment: mode == GameMode.buzzer
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              segment(GameMode.buzzer, Icons.bolt_rounded, 'Buzzer Game'),
              segment(GameMode.quiz, Icons.sports_esports_rounded, 'Quiz Game'),
            ],
          ),
        ],
      ),
    );
  }
}

/// Short explanation of the selected mode.
class _ModeInfo extends StatelessWidget {
  const _ModeInfo({super.key, required this.mode});

  final GameMode mode;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final points = mode == GameMode.buzzer
        ? const [
            'Questions appear on an external screen.',
            'Players select answers on their phones.',
            'Optimized for live, synchronized competitions.',
          ]
        : const [
            "Questions and options appear together on the player's phone.",
            'Self-contained mobile quiz participation.',
          ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < points.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == points.length - 1 ? 0 : 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      points[i],
                      style: text.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.8),
                        height: 1.35,
                      ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primaryContainer,
                ),
                child: Icon(icon, size: 18, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.isError = false,
  });

  final String message;
  final IconData icon;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isError ? cs.error : cs.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : icon,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: isError
                    ? cs.error
                    : cs.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashed upload area.
class _PdfDropZone extends StatefulWidget {
  const _PdfDropZone({
    super.key,
    required this.loading,
    required this.hasError,
    required this.maxMb,
    required this.onTap,
  });

  final bool loading;
  final bool hasError;
  final int maxMb;
  final VoidCallback onTap;

  @override
  State<_PdfDropZone> createState() => _PdfDropZoneState();
}

class _PdfDropZoneState extends State<_PdfDropZone> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final color = widget.hasError ? cs.error : cs.primary;

    return AnimatedScale(
      duration: const Duration(milliseconds: 140),
      scale: _pressed ? 0.98 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.loading ? null : widget.onTap,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: color.withValues(alpha: 0.7),
            radius: 20,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primaryContainer,
                  ),
                  child: widget.loading
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            color: cs.onPrimaryContainer,
                          ),
                        )
                      : Icon(
                          Icons.upload_file_rounded,
                          size: 28,
                          color: cs.onPrimaryContainer,
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Upload questions PDF',
                  style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PDF with questions & answers • up to ${widget.maxMb} MB',
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    'Choose PDF',
                    style: TextStyle(color: color, fontWeight: FontWeight.w700),
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

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    const dash = 8.0;
    const gap = 6.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + dash, metric.length)),
          paint,
        );
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

/// Selected PDF.
class _PdfTile extends StatelessWidget {
  const _PdfTile({
    super.key,
    required this.name,
    required this.size,
    required this.onReplace,
    required this.onRemove,
  });

  final String name;
  final String size;
  final VoidCallback onReplace;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: cs.errorContainer,
            ),
            child: Icon(
              Icons.picture_as_pdf_rounded,
              color: cs.onErrorContainer,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ready • $size',
                      style: text.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Replace',
            onPressed: onRemove == null ? null : onReplace,
            icon: const Icon(Icons.swap_horiz_rounded),
            color: cs.primary,
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded),
            color: cs.error,
          ),
        ],
      ),
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
                            Icon(
                              Icons.add_rounded,
                              color: cs.onPrimary,
                              size: 22,
                            ),
                            const SizedBox(width: 6),
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

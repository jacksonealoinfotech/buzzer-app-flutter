import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum GameMode { buzzer, quiz }

enum GameStatus { draft, scheduled, live, completed }

/// A game created by the host.
class HostGame {
  const HostGame({
    required this.id,
    required this.title,
    required this.mode,
    required this.status,
    required this.questionCount,
    required this.players,
    required this.maxPlayers,
    this.startsAt,
  });

  final String id;
  final String title;
  final GameMode mode;
  final GameStatus status;
  final int questionCount;
  final int players;
  final int maxPlayers;
  final DateTime? startsAt;
}

enum _Filter { all, draft, scheduled, live, completed }

enum _Sort { defaultOrder, newest, oldest, title }

/// Buzzer – Host Dashboard (Home) screen.
///
/// • Uses `Theme.of(context).colorScheme` for everything → light/dark works.
///   Only the "Live" green isn't in a Material ColorScheme: pass
///   [successColor] / [onSuccessColor] from your AppColors (fallback provided).
/// • Requires Flutter 3.27+ (`Color.withValues`).
class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({
    super.key,
    required this.hostName,
    required this.games,
    this.avatarUrl,
    this.onCreateGame,
    this.onGameTap,
    this.onSettings,
    this.onProfileTap,
    this.onRefresh,
    this.successColor = const Color(0xFF16A34A),
    this.onSuccessColor = Colors.white,
  });

  final String hostName;
  final List<HostGame> games;
  final String? avatarUrl;

  final VoidCallback? onCreateGame;
  final ValueChanged<HostGame>? onGameTap;
  final VoidCallback? onSettings;
  final VoidCallback? onProfileTap;

  /// Pull-to-refresh.
  final Future<void> Function()? onRefresh;

  final Color successColor;
  final Color onSuccessColor;

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;

  late final Animation<double> _headerAnim;
  late final Animation<double> _greetingAnim;
  late final Animation<double> _buttonAnim;
  late final Animation<double> _statsAnim;
  late final Animation<double> _searchAnim;
  late final Animation<double> _chipsAnim;
  late final Animation<double> _listAnim;

  final _searchCtrl = TextEditingController();
  _Filter _filter = _Filter.all;
  _Sort _sort = _Sort.defaultOrder;
  String _query = '';

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
    _greetingAnim = stagger(0.08, 0.38);
    _buttonAnim = stagger(0.18, 0.48);
    _statsAnim = stagger(0.28, 0.60);
    _searchAnim = stagger(0.40, 0.70);
    _chipsAnim = stagger(0.48, 0.78);
    _listAnim = stagger(0.55, 1.0);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────── Data helpers ─────────────────────────

  int _count(GameStatus s) => widget.games.where((g) => g.status == s).length;

  GameStatus? _statusOf(_Filter f) {
    switch (f) {
      case _Filter.all:
        return null;
      case _Filter.draft:
        return GameStatus.draft;
      case _Filter.scheduled:
        return GameStatus.scheduled;
      case _Filter.live:
        return GameStatus.live;
      case _Filter.completed:
        return GameStatus.completed;
    }
  }

  List<HostGame> get _visible {
    final status = _statusOf(_filter);
    var list = widget.games.where((g) {
      final okStatus = status == null || g.status == status;
      final okQuery = _query.isEmpty || g.title.toLowerCase().contains(_query);
      return okStatus && okQuery;
    }).toList();

    int cmpDate(HostGame a, HostGame b) {
      final da = a.startsAt, db = b.startsAt;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    }

    switch (_sort) {
      case _Sort.defaultOrder:
        break;
      case _Sort.newest:
        list.sort((a, b) => cmpDate(b, a));
        break;
      case _Sort.oldest:
        list.sort(cmpDate);
        break;
      case _Sort.title:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }
    return list;
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _setFilter(_Filter f) {
    if (_filter == f) return;
    HapticFeedback.selectionClick();
    setState(() => _filter = f);
  }

  Future<void> _openSort() async {
    final cs = Theme.of(context).colorScheme;
    final picked = await showModalBottomSheet<_Sort>(
      context: context,
      backgroundColor: cs.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        const labels = {
          _Sort.defaultOrder: 'Default',
          _Sort.newest: 'Date: newest first',
          _Sort.oldest: 'Date: oldest first',
          _Sort.title: 'Title: A–Z',
        };
        return SafeArea(
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
                      'Sort games',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                for (final entry in labels.entries)
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    title: Text(entry.value),
                    trailing: _sort == entry.key
                        ? Icon(Icons.check_rounded, color: cs.primary)
                        : null,
                    onTap: () => Navigator.pop(context, entry.key),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (picked != null && mounted) setState(() => _sort = picked);
  }

  // ───────────────────────── UI ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.6);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final games = _visible;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: cs.surface,
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)),
            ),
          ),
          child: NavigationBar(
            selectedIndex: 0,
            backgroundColor: cs.surfaceContainerLowest,
            indicatorColor: cs.primaryContainer,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            onDestinationSelected: (i) {
              HapticFeedback.selectionClick();
              if (i == 1) widget.onCreateGame?.call();
              if (i == 2) widget.onSettings?.call();
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline_rounded),
                selectedIcon: Icon(Icons.add_circle_rounded),
                label: 'Create',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            _Background(animation: _float),
            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                color: cs.primary,
                backgroundColor: cs.surfaceContainerLowest,
                onRefresh: widget.onRefresh ?? () async {},
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // Logo + avatar
                              _Reveal(
                                animation: _headerAnim,
                                child: Row(
                                  children: [
                                    const _BuzzerLogo(),
                                    const Spacer(),
                                    _Avatar(
                                      name: widget.hostName,
                                      url: widget.avatarUrl,
                                      onTap: widget.onProfileTap,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Greeting
                              _Reveal(
                                animation: _greetingAnim,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$_greeting, ${widget.hostName}! 👋',
                                      style: text.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ready to create something amazing?',
                                      style: text.bodyMedium?.copyWith(
                                        color: muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Create game
                              _Reveal(
                                animation: _buttonAnim,
                                child: _CreateButton(
                                  animation: _float,
                                  onPressed: widget.onCreateGame,
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Stats
                              _Reveal(
                                animation: _statsAnim,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _StatCard(
                                        label: 'Total Games',
                                        value: widget.games.length,
                                        selected: _filter == _Filter.all,
                                        onTap: () => _setFilter(_Filter.all),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _StatCard(
                                        label: 'Scheduled',
                                        value: _count(GameStatus.scheduled),
                                        selected: _filter == _Filter.scheduled,
                                        onTap: () =>
                                            _setFilter(_Filter.scheduled),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _StatCard(
                                        label: 'Live',
                                        value: _count(GameStatus.live),
                                        selected: _filter == _Filter.live,
                                        accent: widget.successColor,
                                        pulse: _float,
                                        onTap: () => _setFilter(_Filter.live),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _StatCard(
                                        label: 'Completed',
                                        value: _count(GameStatus.completed),
                                        selected: _filter == _Filter.completed,
                                        onTap: () =>
                                            _setFilter(_Filter.completed),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Search + sort
                              _Reveal(
                                animation: _searchAnim,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _SearchField(
                                        controller: _searchCtrl,
                                        onChanged: (v) => setState(
                                          () => _query = v.trim().toLowerCase(),
                                        ),
                                        onClear: () {
                                          _searchCtrl.clear();
                                          setState(() => _query = '');
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _SortButton(
                                      active: _sort != _Sort.defaultOrder,
                                      onTap: _openSort,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Filter chips
                              _Reveal(
                                animation: _chipsAnim,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  clipBehavior: Clip.none,
                                  child: Row(
                                    children: [
                                      for (final f in _Filter.values) ...[
                                        _FilterChip(
                                          label: _labelOf(f),
                                          selected: _filter == f,
                                          onTap: () => _setFilter(f),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Game list
                              _Reveal(
                                animation: _listAnim,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Your games',
                                          style: text.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: cs.onSurface,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${games.length}',
                                          style: text.labelLarge?.copyWith(
                                            color: muted,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      transitionBuilder: (child, anim) =>
                                          FadeTransition(
                                            opacity: anim,
                                            child: child,
                                          ),
                                      layoutBuilder: (current, previous) =>
                                          Stack(
                                            alignment: Alignment.topCenter,
                                            children: [
                                              ...previous,
                                              if (current != null) current,
                                            ],
                                          ),
                                      child: games.isEmpty
                                          ? _EmptyState(
                                              key: const ValueKey('empty'),
                                              searching: _query.isNotEmpty,
                                              onCreate: widget.onCreateGame,
                                            )
                                          : Column(
                                              key: ValueKey(
                                                '$_filter|$_query|$_sort|${games.length}',
                                              ),
                                              children: [
                                                for (
                                                  var i = 0;
                                                  i < games.length;
                                                  i++
                                                )
                                                  _StaggerIn(
                                                    index: i,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 12,
                                                          ),
                                                      child: _GameCard(
                                                        game: games[i],
                                                        pulse: _float,
                                                        successColor:
                                                            widget.successColor,
                                                        onSuccessColor: widget
                                                            .onSuccessColor,
                                                        onTap: () => widget
                                                            .onGameTap
                                                            ?.call(games[i]),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
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
    );
  }

  String _labelOf(_Filter f) {
    switch (f) {
      case _Filter.all:
        return 'All';
      case _Filter.draft:
        return 'Draft';
      case _Filter.scheduled:
        return 'Scheduled';
      case _Filter.live:
        return 'Live';
      case _Filter.completed:
        return 'Completed';
    }
  }
}

// ───────────────────────── Widgets ─────────────────────────

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.animation, required this.onPressed});

  final Animation<double> animation;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(
                alpha: 0.22 + 0.12 * animation.value,
              ),
              blurRadius: 18 + 8 * animation.value,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
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
            onTap: onPressed == null
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onPressed!();
                  },
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: cs.onPrimary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Create Game',
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
    this.accent,
    this.pulse,
  });

  final String label;
  final int value;
  final bool selected;
  final VoidCallback onTap;
  final Color? accent;
  final Animation<double>? pulse;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final numberColor = (accent != null && value > 0) ? accent! : cs.onSurface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: selected
              ? cs.primaryContainer.withValues(alpha: 0.6)
              : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 14,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (pulse != null && value > 0) ...[
                      AnimatedBuilder(
                        animation: pulse!,
                        builder: (context, _) => Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: numberColor.withValues(
                              alpha: 0.4 + 0.6 * pulse!.value,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => Text(
                '$v',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: numberColor,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c, width: w),
    );

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search games...',
          hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)),
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear',
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: cs.surfaceContainerLowest,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: border(cs.outlineVariant),
          enabledBorder: border(cs.outlineVariant),
          focusedBorder: border(cs.primary, 1.8),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Sort',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: active ? cs.primary : cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: active ? cs.primary : cs.outlineVariant),
          ),
          child: Icon(
            Icons.tune_rounded,
            color: active ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? cs.primary : cs.outlineVariant),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            color: selected
                ? cs.onPrimary
                : cs.onSurface.withValues(alpha: 0.75),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _GameCard extends StatefulWidget {
  const _GameCard({
    required this.game,
    required this.pulse,
    required this.successColor,
    required this.onSuccessColor,
    required this.onTap,
  });

  final HostGame game;
  final Animation<double> pulse;
  final Color successColor;
  final Color onSuccessColor;
  final VoidCallback onTap;

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool _pressed = false;

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

  String _fmt(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final mm = d.minute.toString().padLeft(2, '0');
    final ap = d.hour < 12 ? 'AM' : 'PM';
    return '${_months[d.month - 1]} ${d.day}, ${d.year} • $h12:$mm $ap';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final g = widget.game;
    final muted = cs.onSurface.withValues(alpha: 0.6);
    final isBuzzer = g.mode == GameMode.buzzer;

    return AnimatedScale(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      scale: _pressed ? 0.98 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.8)),
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isBuzzer ? cs.primaryContainer : cs.tertiaryContainer,
                ),
                child: Icon(
                  isBuzzer ? Icons.bolt_rounded : Icons.sports_esports_rounded,
                  color: isBuzzer
                      ? cs.onPrimaryContainer
                      : cs.onTertiaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            g.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(
                          status: g.status,
                          pulse: widget.pulse,
                          successColor: widget.successColor,
                          onSuccessColor: widget.onSuccessColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isBuzzer ? 'Buzzer Game' : 'Quiz Game',
                      style: text.labelSmall?.copyWith(color: muted),
                    ),
                    const SizedBox(height: 8),
                    _Meta(
                      icon: Icons.schedule_rounded,
                      label: g.startsAt == null
                          ? 'Not scheduled'
                          : _fmt(g.startsAt!),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 14,
                      runSpacing: 4,
                      children: [
                        _Meta(
                          icon: Icons.quiz_outlined,
                          label: '${g.questionCount} questions',
                        ),
                        _Meta(
                          icon: Icons.groups_outlined,
                          label: '${g.players}/${g.maxPlayers}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = cs.onSurface.withValues(alpha: 0.6);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ),
      ],
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

    late final Color bg;
    late final Color fg;
    late final String label;
    switch (status) {
      case GameStatus.live:
        bg = successColor;
        fg = onSuccessColor;
        label = 'Live';
        break;
      case GameStatus.scheduled:
        bg = cs.primaryContainer;
        fg = cs.onPrimaryContainer;
        label = 'Scheduled';
        break;
      case GameStatus.draft:
        bg = cs.surfaceContainerHigh;
        fg = cs.onSurface.withValues(alpha: 0.7);
        label = 'Draft';
        break;
      case GameStatus.completed:
        bg = cs.secondaryContainer;
        fg = cs.onSecondaryContainer;
        label = 'Completed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key, required this.searching, this.onCreate});

  final bool searching;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primaryContainer,
            ),
            child: Icon(
              searching ? Icons.search_off_rounded : Icons.bolt_rounded,
              size: 32,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No games found',
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            searching
                ? 'Try a different search or filter.'
                : 'Tap “Create Game” to get started.',
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (!searching && onCreate != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Game'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.url, this.onTap});

  final String name;
  final String? url;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: cs.primaryContainer,
          backgroundImage: url != null ? NetworkImage(url!) : null,
          child: url == null
              ? Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: TextStyle(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

/// Staggered fade/slide-in for list items (replays when the list is rebuilt
/// under a new key).
class _StaggerIn extends StatelessWidget {
  const _StaggerIn({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ms = 350 + (index.clamp(0, 8)) * 90;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - v)),
          child: child,
        ),
      ),
      child: child,
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

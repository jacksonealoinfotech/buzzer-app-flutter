import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Switches shown on the settings screen.
enum SettingsToggle {
  gameReminders,
  playerActivity,
  gameResults,
  soundEffects,
  haptics,
}

enum _Tone { primary, secondary, tertiary, error }

/// Buzzer – Settings screen (host).
///
/// • Uses ONLY `Theme.of(context).colorScheme` → light/dark works automatically.
/// • The Appearance selector (System / Light / Dark) calls
///   [onThemeModeChanged] – wire it to the `themeMode` of your MaterialApp.
/// • Requires Flutter 3.27+ (`Color.withValues`).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.hostName,
    required this.email,
    this.avatarUrl,
    this.themeMode = ThemeMode.system,
    this.onThemeModeChanged,
    this.gameReminders = true,
    this.playerActivity = true,
    this.gameResults = true,
    this.soundEffects = true,
    this.haptics = true,
    this.onToggle,
    this.onEditProfile,
    this.onChangePassword,
    this.onHelp,
    this.onPrivacy,
    this.onTerms,
    this.onLogout,
    this.onDeleteAccount,
    this.appVersion = '1.0.0',
    this.showBackButton = true,
  });

  final String hostName;
  final String email;
  final String? avatarUrl;

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  final bool gameReminders;
  final bool playerActivity;
  final bool gameResults;
  final bool soundEffects;
  final bool haptics;

  /// Persist the switch value (shared prefs / backend).
  final void Function(SettingsToggle toggle, bool value)? onToggle;

  final VoidCallback? onEditProfile;
  final VoidCallback? onChangePassword;
  final VoidCallback? onHelp;
  final VoidCallback? onPrivacy;
  final VoidCallback? onTerms;

  /// Called after the user confirms. Show a spinner while it runs.
  final Future<void> Function()? onLogout;

  /// When null the "Delete account" option is hidden.
  final Future<void> Function()? onDeleteAccount;

  final String appVersion;
  final bool showBackButton;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;

  late final Animation<double> _headerAnim;
  late final Animation<double> _profileAnim;
  late final Animation<double> _appearanceAnim;
  late final Animation<double> _notifAnim;
  late final Animation<double> _accountAnim;
  late final Animation<double> _supportAnim;
  late final Animation<double> _logoutAnim;

  late ThemeMode _themeMode;
  late final Map<SettingsToggle, bool> _toggles;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();

    _themeMode = widget.themeMode;
    _toggles = {
      SettingsToggle.gameReminders: widget.gameReminders,
      SettingsToggle.playerActivity: widget.playerActivity,
      SettingsToggle.gameResults: widget.gameResults,
      SettingsToggle.soundEffects: widget.soundEffects,
      SettingsToggle.haptics: widget.haptics,
    };

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    Animation<double> stagger(double b, double e) => CurvedAnimation(
      parent: _entrance,
      curve: Interval(b, e, curve: Curves.easeOutCubic),
    );
    _headerAnim = stagger(0.0, 0.25);
    _profileAnim = stagger(0.08, 0.38);
    _appearanceAnim = stagger(0.20, 0.50);
    _notifAnim = stagger(0.32, 0.62);
    _accountAnim = stagger(0.44, 0.74);
    _supportAnim = stagger(0.56, 0.86);
    _logoutAnim = stagger(0.68, 1.0);
  }

  @override
  void didUpdateWidget(covariant SettingsScreen old) {
    super.didUpdateWidget(old);
    if (widget.themeMode != old.themeMode) _themeMode = widget.themeMode;
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    super.dispose();
  }

  void _setTheme(ThemeMode m) {
    if (m == _themeMode) return;
    HapticFeedback.selectionClick();
    setState(() => _themeMode = m);
    widget.onThemeModeChanged?.call(m);
  }

  void _toggle(SettingsToggle t, bool v) {
    HapticFeedback.selectionClick();
    setState(() => _toggles[t] = v);
    widget.onToggle?.call(t, v);
  }

  Future<void> _confirmLogout() async {
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Icon(Icons.logout_rounded, color: cs.error),
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to host games.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _loggingOut = true);
    try {
      await widget.onLogout?.call();
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  Future<void> _confirmDelete() async {
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Icon(Icons.warning_amber_rounded, color: cs.error),
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account and all your games. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep account'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) await widget.onDeleteAccount?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.6);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Stack(
          children: [
            _Background(animation: _float),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _Reveal(
                          animation: _headerAnim,
                          child: Row(
                            children: [
                              if (widget.showBackButton)
                                IconButton(
                                  tooltip: 'Back',
                                  onPressed: () => Navigator.maybePop(context),
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  color: cs.onSurface,
                                )
                              else
                                const SizedBox(width: 12),
                              Text(
                                'Settings',
                                style: text.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Profile
                        _Reveal(
                          animation: _profileAnim,
                          child: _ProfileCard(
                            name: widget.hostName,
                            email: widget.email,
                            avatarUrl: widget.avatarUrl,
                            onTap: widget.onEditProfile,
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Appearance
                        _Reveal(
                          animation: _appearanceAnim,
                          child: _Section(
                            title: 'Appearance',
                            child: _Card(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ThemeSelector(
                                    mode: _themeMode,
                                    onChanged: _setTheme,
                                  ),
                                  const SizedBox(height: 10),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: Padding(
                                      key: ValueKey(_themeMode),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Text(
                                        switch (_themeMode) {
                                          ThemeMode.system =>
                                            'Matches your device appearance.',
                                          ThemeMode.light =>
                                            'Always use the light theme.',
                                          ThemeMode.dark =>
                                            'Always use the dark theme.',
                                        },
                                        style: text.bodySmall?.copyWith(
                                          color: muted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Notifications + sound
                        _Reveal(
                          animation: _notifAnim,
                          child: _Section(
                            title: 'Notifications & feedback',
                            child: _Card(
                              child: Column(
                                children: [
                                  _SwitchTile(
                                    icon: Icons.alarm_rounded,
                                    tone: _Tone.primary,
                                    title: 'Game reminders',
                                    subtitle:
                                        'Before your scheduled games start',
                                    value:
                                        _toggles[SettingsToggle.gameReminders]!,
                                    onChanged: (v) => _toggle(
                                      SettingsToggle.gameReminders,
                                      v,
                                    ),
                                  ),
                                  const _TileDivider(),
                                  _SwitchTile(
                                    icon: Icons.group_add_rounded,
                                    tone: _Tone.tertiary,
                                    title: 'Player activity',
                                    subtitle: 'When players register or join',
                                    value:
                                        _toggles[SettingsToggle
                                            .playerActivity]!,
                                    onChanged: (v) => _toggle(
                                      SettingsToggle.playerActivity,
                                      v,
                                    ),
                                  ),
                                  const _TileDivider(),
                                  _SwitchTile(
                                    icon: Icons.emoji_events_rounded,
                                    tone: _Tone.secondary,
                                    title: 'Game results',
                                    subtitle: 'When a game finishes',
                                    value:
                                        _toggles[SettingsToggle.gameResults]!,
                                    onChanged: (v) =>
                                        _toggle(SettingsToggle.gameResults, v),
                                  ),
                                  const _TileDivider(),
                                  _SwitchTile(
                                    icon: Icons.volume_up_rounded,
                                    tone: _Tone.primary,
                                    title: 'Sound effects',
                                    value:
                                        _toggles[SettingsToggle.soundEffects]!,
                                    onChanged: (v) =>
                                        _toggle(SettingsToggle.soundEffects, v),
                                  ),
                                  const _TileDivider(),
                                  _SwitchTile(
                                    icon: Icons.vibration_rounded,
                                    tone: _Tone.tertiary,
                                    title: 'Haptic feedback',
                                    value: _toggles[SettingsToggle.haptics]!,
                                    onChanged: (v) =>
                                        _toggle(SettingsToggle.haptics, v),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Account
                        _Reveal(
                          animation: _accountAnim,
                          child: _Section(
                            title: 'Account',
                            child: _Card(
                              child: Column(
                                children: [
                                  _NavTile(
                                    icon: Icons.person_outline_rounded,
                                    tone: _Tone.primary,
                                    title: 'Edit profile',
                                    onTap: widget.onEditProfile,
                                  ),
                                  const _TileDivider(),
                                  _NavTile(
                                    icon: Icons.lock_outline_rounded,
                                    tone: _Tone.secondary,
                                    title: 'Change password',
                                    onTap: widget.onChangePassword,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Support & legal
                        _Reveal(
                          animation: _supportAnim,
                          child: _Section(
                            title: 'Support',
                            child: _Card(
                              child: Column(
                                children: [
                                  _NavTile(
                                    icon: Icons.help_outline_rounded,
                                    tone: _Tone.tertiary,
                                    title: 'Help & support',
                                    onTap: widget.onHelp,
                                  ),
                                  const _TileDivider(),
                                  _NavTile(
                                    icon: Icons.shield_outlined,
                                    tone: _Tone.primary,
                                    title: 'Privacy policy',
                                    onTap: widget.onPrivacy,
                                  ),
                                  const _TileDivider(),
                                  _NavTile(
                                    icon: Icons.description_outlined,
                                    tone: _Tone.secondary,
                                    title: 'Terms of service',
                                    onTap: widget.onTerms,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Logout + delete + version
                        _Reveal(
                          animation: _logoutAnim,
                          child: Column(
                            children: [
                              _LogoutButton(
                                loading: _loggingOut,
                                onPressed: _loggingOut ? null : _confirmLogout,
                              ),
                              if (widget.onDeleteAccount != null) ...[
                                const SizedBox(height: 6),
                                TextButton(
                                  onPressed: _loggingOut
                                      ? null
                                      : _confirmDelete,
                                  style: TextButton.styleFrom(
                                    foregroundColor: cs.error,
                                  ),
                                  child: const Text('Delete account'),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (rect) => LinearGradient(
                                      colors: [cs.primary, cs.tertiary],
                                    ).createShader(rect),
                                    child: const Icon(
                                      Icons.bolt_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Buzzer  •  v${widget.appVersion}',
                                    style: text.bodySmall?.copyWith(
                                      color: muted,
                                    ),
                                  ),
                                ],
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
    );
  }
}

// ───────────────────────── Widgets ─────────────────────────

class _ProfileCard extends StatefulWidget {
  const _ProfileCard({
    required this.name,
    required this.email,
    this.avatarUrl,
    this.onTap,
  });

  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback? onTap;

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AnimatedScale(
      duration: const Duration(milliseconds: 140),
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
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                cs.primaryContainer.withValues(alpha: 0.9),
                cs.tertiaryContainer.withValues(alpha: 0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: cs.surfaceContainerLowest,
                  backgroundImage: widget.avatarUrl != null
                      ? NetworkImage(widget.avatarUrl!)
                      : null,
                  child: widget.avatarUrl == null
                      ? Text(
                          widget.name.isEmpty
                              ? '?'
                              : widget.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_outlined,
                size: 20,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// System / Light / Dark with a sliding indicator.
class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget segment(ThemeMode m, IconData icon, String label) {
      final selected = mode == m;
      final color = selected
          ? cs.onPrimary
          : cs.onSurface.withValues(alpha: 0.7);
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(m),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  scale: selected ? 1.15 : 1,
                  child: Icon(icon, size: 22, color: color),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final x = switch (mode) {
      ThemeMode.system => -1.0,
      ThemeMode.light => 0.0,
      ThemeMode.dark => 1.0,
    };

    return Container(
      height: 68,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            alignment: Alignment(x, 0),
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
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
              segment(
                ThemeMode.system,
                Icons.brightness_auto_rounded,
                'System',
              ),
              segment(ThemeMode.light, Icons.light_mode_rounded, 'Light'),
              segment(ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      indent: 70,
      endIndent: 16,
      color: cs.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon, required this.tone});

  final IconData icon;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (bg, fg) = switch (tone) {
      _Tone.primary => (cs.primaryContainer, cs.onPrimaryContainer),
      _Tone.secondary => (cs.secondaryContainer, cs.onSecondaryContainer),
      _Tone.tertiary => (cs.tertiaryContainer, cs.onTertiaryContainer),
      _Tone.error => (cs.errorContainer, cs.onErrorContainer),
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: bg,
      ),
      child: Icon(icon, size: 21, color: fg),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.tone,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final _Tone tone;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _IconBubble(icon: icon, tone: tone),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: text.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.tone,
    required this.title,
    this.onTap,
  });

  final IconData icon;
  final _Tone tone;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _IconBubble(icon: icon, tone: tone),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: text.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.errorContainer.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: loading
                  ? SizedBox(
                      key: const ValueKey('loader'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: cs.onErrorContainer,
                      ),
                    )
                  : Row(
                      key: const ValueKey('label'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: cs.onErrorContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Log out',
                          style: TextStyle(
                            color: cs.onErrorContainer,
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

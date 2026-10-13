import 'package:flutter/material.dart';
import 'package:buzzer_app/core/responsive/responsive_context.dart';

/// Navigation item model for adaptive shell scaffolds.
final class AdaptiveNavigationDestination {
  const AdaptiveNavigationDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badgeText,
  });

  final Widget icon;
  final Widget? selectedIcon;
  final String label;
  final String? badgeText;
}

/// Adaptive navigation scaffold switching between:
/// - Bottom [NavigationBar] on compact (phone) screens.
/// - Side [NavigationRail] on medium (tablet) screens.
/// - Persistent side [NavigationDrawer] on expanded (desktop) screens.
class AdaptiveNavigationScaffold extends StatelessWidget {
  const AdaptiveNavigationScaffold({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    super.key,
    this.appBar,
    this.floatingActionButton,
  });

  final List<AdaptiveNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    if (context.isCompact) {
      return Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations.map((dest) {
            return NavigationDestination(
              icon: dest.icon,
              selectedIcon: dest.selectedIcon,
              label: dest.label,
            );
          }).toList(),
        ),
      );
    }

    if (context.isMedium) {
      return Scaffold(
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.selected,
              destinations: destinations.map((dest) {
                return NavigationRailDestination(
                  icon: dest.icon,
                  selectedIcon: dest.selectedIcon ?? dest.icon,
                  label: Text(dest.label),
                );
              }).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    // Expanded / Desktop mode
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          SizedBox(
            width: 280,
            child: NavigationDrawer(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              children: [
                const SizedBox(height: 16),
                ...destinations.map((dest) {
                  return NavigationDrawerDestination(
                    icon: dest.icon,
                    selectedIcon: dest.selectedIcon,
                    label: Text(dest.label),
                  );
                }),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

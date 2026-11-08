import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/settings/presentation/token_cubit.dart';
import '../features/services/domain/entities/service_scope.dart';
import '../features/services/presentation/pages/services_page.dart';
import '../l10n/generated/app_localizations.dart';

/// Four destinations around an elevated brand mark that opens the drawer.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({super.key});

  static const _barHeight = 96.0;
  static const _markSize = 84.0;
  static const _markOverhang = 32.0;
  static const _labelSize = 13.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final signedIn = context.watch<TokenCubit>().state != null;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.brightness == Brightness.light
        ? Colors.white
        : theme.colorScheme.surfaceContainerHigh;
    final inactive = theme.brightness == Brightness.light
        ? const Color(0xFF777B85)
        : theme.colorScheme.onSurfaceVariant;
    // The overhang is real height, not painted overflow: a Stack does not hit
    // test outside its own size, so an overflowing mark would be half untappable.
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final labelGrowth =
        MediaQuery.textScalerOf(context).scale(_labelSize) - _labelSize;
    final barHeight = _barHeight + bottomInset + labelGrowth * 1.5;

    return SizedBox(
      height: barHeight + _markOverhang,
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(42),
                  bottomRight: Radius.circular(42),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 15,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 10,
                    right: 10,
                    bottom: 6,
                  ),
                  child: Row(
                    children: [
                      _NavItem(
                        key: const ValueKey('nav-account'),
                        icon: Icons.person_outline_rounded,
                        label: l10n.accountTitle,
                        color: inactive,
                        onTap: () => context.push(signedIn ? '/profile' : '/login'),
                      ),
                      _NavItem(
                        key: const ValueKey('nav-favorites'),
                        icon: Icons.favorite_border_rounded,
                        label: l10n.favoritesTitle,
                        color: inactive,
                        onTap: () => context.push(
                          '/services',
                          extra: ServicesRouteArgs(
                            scope: ServiceScope.favorites,
                            title: l10n.favoritesTitle,
                          ),
                        ),
                      ),
                      // Keeps the two halves clear of the mark above them.
                      const Expanded(child: SizedBox()),
                      _NavItem(
                        key: const ValueKey('nav-categories'),
                        icon: Icons.grid_view_rounded,
                        label: l10n.navCategories,
                        color: inactive,
                        onTap: () => context.push('/categories'),
                      ),
                      _NavItem(
                        key: const ValueKey('nav-home'),
                        icon: Icons.home_rounded,
                        label: l10n.navHome,
                        color: primary,
                        selected: true,
                        onTap: () {
                          // Already on the home page.
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Tooltip(
              message: l10n.navMenu,
              child: GestureDetector(
                key: const ValueKey('nav-menu'),
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  width: _markSize,
                  height: _markSize,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    // The mark is blue art on transparency, so it keeps a light
                    // badge in both themes rather than sinking into a dark one.
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.13),
                        blurRadius: 22,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const _BrandMark(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The tower inside the ring, laid out at the splash's own proportions.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 280,
        height: 320,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 65,
              child: Image.asset(
                'assets/images/circle.png',
                width: 190,
                height: 190,
                fit: BoxFit.contain,
              ),
            ),
            Image.asset(
              'assets/images/tower.png',
              width: 240,
              height: 310,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 26, color: color),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color,
                      fontSize: AppBottomBar._labelSize,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
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
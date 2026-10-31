import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/settings/presentation/locale_cubit.dart';
import '../core/settings/presentation/theme_cubit.dart';
import '../core/theme/app_theme.dart';
import '../features/tutorial/presentation/tutorial_cubit.dart';
import '../l10n/generated/app_localizations.dart';

/// Navigation drawer holding app-wide preferences: language and theme.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _DrawerHeader(title: l10n.appTitle, tagline: l10n.appTagline),
            const SizedBox(height: 8),
            ListTile(
              key: const ValueKey('drawer-language'),
              leading: Icon(
                Icons.translate_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(l10n.language),
              subtitle: Text(l10n.changeLanguage),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                final localeCubit = context.read<LocaleCubit>();
                Navigator.of(context).pop();
                localeCubit.toggle();
              },
            ),
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) {
                final isDark = switch (mode) {
                  ThemeMode.dark => true,
                  ThemeMode.light => false,
                  ThemeMode.system =>
                    MediaQuery.platformBrightnessOf(context) == Brightness.dark,
                };
                return SwitchListTile(
                  key: const ValueKey('drawer-theme'),
                  secondary: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.darkMode),
                  value: isDark,
                  onChanged: (value) => context.read<ThemeCubit>().setMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              key: const ValueKey('drawer-tutorial'),
              leading: Icon(
                Icons.school_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(l10n.tutorialMenu),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                final tutorialCubit = context.read<TutorialCubit>();
                Navigator.of(context).pop();
                tutorialCubit.restart();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.title, required this.tagline});

  final String title;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(24, 28, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AppTheme.brand, AppTheme.brandDeep],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(Icons.place_rounded, color: AppTheme.brand),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tagline,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

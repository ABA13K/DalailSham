import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/settings/presentation/locale_cubit.dart';
import '../core/settings/presentation/theme_cubit.dart';
import '../core/settings/presentation/token_cubit.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/services/domain/entities/service_scope.dart';
import '../features/services/presentation/pages/services_page.dart';
import '../features/tutorial/presentation/tutorial_cubit.dart';
import '../l10n/generated/app_localizations.dart';

/// Navigation drawer holding the account and the app-wide preferences:
/// favorites, language, theme and the guided tour.
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
            const _AccountSection(),
            ListTile(
              key: const ValueKey('drawer-favorites'),
              leading: Icon(
                Icons.favorite_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(l10n.favoritesTitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).pop();
                context.push(
                  '/services',
                  extra: ServicesRouteArgs(
                    scope: ServiceScope.favorites,
                    title: l10n.favoritesTitle,
                  ),
                );
              },
            ),
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

/// The account row: login and register while signed out, the profile and a
/// sign-out once a bearer token is stored.
class _AccountSection extends StatelessWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<TokenCubit, String?>(
      builder: (context, token) => token == null
          ? Column(
              children: [
                ListTile(
                  key: const ValueKey('drawer-login'),
                  leading: Icon(
                    Icons.login_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.loginTitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/login');
                  },
                ),
                ListTile(
                  key: const ValueKey('drawer-register'),
                  leading: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.registerTitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/register');
                  },
                ),
                ListTile(
                  key: const ValueKey('drawer-vendor-join'),
                  leading: Icon(
                    Icons.storefront_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.vendorJoinTitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/vendor/join-request');
                  },
                ),
                const Divider(height: 1),
              ],
            )
          : Column(
              children: [
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final user = state.user;
                    final contact = user?.contact ?? '';
                    return ListTile(
                      key: const ValueKey('drawer-account'),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          _initials(user?.fullName),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      title: Text(
                        user?.fullName ?? l10n.accountTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: contact.isEmpty
                          ? null
                          : Text(
                              contact,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/profile');
                      },
                    );
                  },
                ),
                // Only a vendor account owns the service the /vendor/service
                // endpoints edit, so nobody else is offered the row.
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) => state.user?.isVendor ?? false
                      ? ListTile(
                          key: const ValueKey('drawer-vendor-service'),
                          leading: Icon(
                            Icons.storefront_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(l10n.vendorServiceTitle),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push('/vendor/service');
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) => state.user?.isVendor ?? false
                      ? ListTile(
                          key: const ValueKey('drawer-vendor-contacts'),
                          leading: Icon(
                            Icons.contact_page_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(l10n.vendorContactsTitle),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push('/vendor/contacts');
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) => state.user?.isVendor ?? false
                      ? ListTile(
                          key: const ValueKey('drawer-vendor-images'),
                          leading: Icon(
                            Icons.photo_library_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(l10n.vendorImagesTitle),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push('/vendor/images');
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) => state.user?.isVendor ?? false
                      ? ListTile(
                          key: const ValueKey('drawer-vendor-products'),
                          leading: Icon(
                            Icons.inventory_2_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(l10n.vendorProductsTitle),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push('/vendor/products');
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) => state.user?.isVendor ?? false
                      ? ListTile(
                          key: const ValueKey('drawer-vendor-amenities'),
                          leading: Icon(
                            Icons.checkroom_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(l10n.vendorAmenitiesTitle),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push('/vendor/amenities');
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                // A story is posted to the vendor's own service, so the row sits
                // behind the same account check as the rest of the vendor list.
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) => state.user?.isVendor ?? false
                      ? ListTile(
                          key: const ValueKey('drawer-vendor-stories'),
                          leading: Icon(
                            Icons.auto_stories_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(l10n.vendorStoriesTitle),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push('/vendor/story');
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                ListTile(
                  key: const ValueKey('drawer-logout'),
                  leading: Icon(
                    Icons.logout_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.logout),
                  onTap: () {
                    final auth = context.read<AuthCubit>();
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(context).pop();
                    auth.signOut();
                    messenger
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(l10n.signedOut)));
                  },
                ),
                const Divider(height: 1),
              ],
            ),
    );
  }

  static String _initials(String? name) {
    final words = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    return words
        .take(2)
        .map((word) => String.fromCharCode(word.runes.first))
        .join();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/centered_content.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/vendor_amenity.dart';
import '../../domain/repositories/vendor_amenity_repository.dart';
import '../cubit/vendor_amenities_cubit.dart';
import 'vendor_amenity_form_page.dart';

/// `GET /vendor/amenities` — what the signed-in vendor offers with the service.
///
/// A new or rewritten amenity waits for an admin, so each row says which side
/// of that approval it is on. The vendor can add until the endpoint says there
/// is no room left, edit one line, or clear the whole set.
class VendorAmenitiesPage extends StatefulWidget {
  const VendorAmenitiesPage({super.key});

  @override
  State<VendorAmenitiesPage> createState() => _VendorAmenitiesPageState();
}

class _VendorAmenitiesPageState extends State<VendorAmenitiesPage> {
  late final VendorAmenitiesCubit _cubit;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _cubit = VendorAmenitiesCubit(getIt<VendorAmenityRepository>());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The language the list is asked for lives in an inherited widget, which
    // only has a value once the first build is under way.
    if (_started) return;
    _started = true;
    _cubit.load(Localizations.localeOf(context).languageCode);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _openForm([VendorAmenity? amenity]) {
    context.push(
      '/vendor/amenities/form',
      extra: VendorAmenityFormArgs(cubit: _cubit, amenity: amenity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.vendorAmenitiesTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            BlocBuilder<VendorAmenitiesCubit, VendorAmenitiesState>(
              builder: (context, state) => state.gallery.amenities.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      key: const ValueKey('amenities-delete-all'),
                      tooltip: l10n.deleteAllAmenities,
                      icon: const Icon(Icons.delete_sweep_outlined),
                      onPressed: state.isBusy ? null : _confirmClear,
                    ),
            ),
          ],
        ),
        body: CenteredContent(
          child: BlocBuilder<VendorAmenitiesCubit, VendorAmenitiesState>(
            builder: (context, state) => switch (state.status) {
              VendorAmenitiesStatus.initial || VendorAmenitiesStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              VendorAmenitiesStatus.failure => _AmenitiesMessage(
                message: l10n.placesError,
                action: FilledButton.icon(
                  key: const ValueKey('amenities-retry'),
                  onPressed: () =>
                      _cubit.load(Localizations.localeOf(context).languageCode),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              ),
              VendorAmenitiesStatus.ready => _AmenityList(
                state: state,
                locale: Localizations.localeOf(context).languageCode,
                onEdit: _openForm,
              ),
            },
          ),
        ),
        floatingActionButton:
            BlocBuilder<VendorAmenitiesCubit, VendorAmenitiesState>(
              builder: (context, state) =>
                  state.status == VendorAmenitiesStatus.ready && !state.isBusy
                  ? FloatingActionButton.extended(
                      key: const ValueKey('amenity-add'),
                      onPressed: state.gallery.canAdd
                          ? () => _openForm()
                          : null,
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.addAmenity),
                    )
                  : const SizedBox.shrink(),
            ),
      ),
    );
  }

  Future<void> _confirmClear() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final removed = _cubit.state.gallery.count;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.deleteAllAmenitiesQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const ValueKey('amenities-clear-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteAllAmenities),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final message = await _cubit.clear();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message ?? l10n.amenitiesRemovedAll(removed))),
      );
  }
}

class _AmenityList extends StatelessWidget {
  const _AmenityList({
    required this.state,
    required this.locale,
    required this.onEdit,
  });

  final VendorAmenitiesState state;
  final String locale;
  final void Function(VendorAmenity amenity) onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final amenities = state.gallery.amenities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.amenitiesIntro,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.amenitiesLimit(amenities.length, state.gallery.maxAllowed),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: amenities.isEmpty
              ? _AmenitiesMessage(message: l10n.amenitiesEmpty)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
                  itemCount: amenities.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _AmenityRow(
                    amenity: amenities[index],
                    locale: locale,
                    isBusy: state.isBusy,
                    onEdit: onEdit,
                  ),
                ),
        ),
        if (!state.gallery.canAdd && amenities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              l10n.amenitiesLimitReached,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class _AmenityRow extends StatelessWidget {
  const _AmenityRow({
    required this.amenity,
    required this.locale,
    required this.isBusy,
    required this.onEdit,
  });

  final VendorAmenity amenity;
  final String locale;
  final bool isBusy;
  final void Function(VendorAmenity amenity) onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final details = [
      ?amenity.otherName(locale),
      if (!amenity.isApproved) l10n.amenityPendingApproval,
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        key: ValueKey('amenity-row-${amenity.id}'),
        enabled: !isBusy,
        onTap: () => onEdit(amenity),
        leading: Icon(
          amenity.isApproved
              ? Icons.check_circle_outline_rounded
              : Icons.hourglass_empty_rounded,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          amenity.nameIn(locale),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: details.isEmpty
            ? null
            : Text(
                details.join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _AmenitiesMessage extends StatelessWidget {
  const _AmenitiesMessage({required this.message, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/centered_content.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/contact_group.dart';
import '../../domain/entities/vendor_contact.dart';
import '../../domain/repositories/vendor_contact_repository.dart';
import '../cubit/vendor_contacts_cubit.dart';
import 'vendor_contact_form_page.dart';

/// `GET /vendor/contacts` — every contact line of the signed-in vendor's
/// service, grouped by the type `GET /vendor/contacts/types` offers.
///
/// Each line can be added, edited, deleted, or made the primary one for its
/// type; the writes run through [VendorContactsCubit], which reads the groups
/// back so the counts and the primary flag are the ones the server chose.
class VendorContactsPage extends StatelessWidget {
  const VendorContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return BlocProvider(
      create: (context) =>
          VendorContactsCubit(getIt<VendorContactRepository>())..load(locale),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.vendorContactsTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: CenteredContent(
          child: BlocBuilder<VendorContactsCubit, VendorContactsState>(
            builder: (context, state) => switch (state.status) {
              VendorContactsStatus.initial || VendorContactsStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              VendorContactsStatus.failure => _ContactsMessage(
                message: l10n.placesError,
                action: FilledButton.icon(
                  key: const ValueKey('contacts-retry'),
                  onPressed: () => context.read<VendorContactsCubit>().load(
                    Localizations.localeOf(context).languageCode,
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              ),
              VendorContactsStatus.ready =>
                state.groups.isEmpty
                    ? _ContactsMessage(message: l10n.contactsEmpty)
                    : _ContactGroups(
                        groups: state.groups,
                        isBusy: state.isSaving,
                      ),
            },
          ),
        ),
        floatingActionButton:
            BlocBuilder<VendorContactsCubit, VendorContactsState>(
              builder: (context, state) =>
                  state.status == VendorContactsStatus.ready && !state.isSaving
                  ? FloatingActionButton.extended(
                      key: const ValueKey('contact-add'),
                      onPressed: () => context.push(
                        '/vendor/contacts/form',
                        extra: VendorContactFormArgs(
                          cubit: context.read<VendorContactsCubit>(),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.addContact),
                    )
                  : const SizedBox.shrink(),
            ),
      ),
    );
  }
}

class _ContactGroups extends StatelessWidget {
  const _ContactGroups({required this.groups, required this.isBusy});

  final List<ContactGroup> groups;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Icon(
                    contactTypeIcon(group.type),
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      group.typeLabel ?? group.type,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${group.count}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            for (final contact in group.contacts)
              _ContactRow(
                key: ValueKey('contact-row-${contact.id}'),
                contact: contact,
                isBusy: isBusy,
              ),
          ],
        );
      },
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({super.key, required this.contact, required this.isBusy});

  final VendorContact contact;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(
        contactTypeIcon(contact.type),
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(contact.value, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: contact.isPrimary
          ? Text(
              l10n.primaryContact,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: ValueKey('contact-primary-${contact.id}'),
            tooltip: l10n.setPrimaryContact,
            icon: Icon(
              contact.isPrimary
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: contact.isPrimary ? theme.colorScheme.primary : null,
            ),
            onPressed: isBusy || contact.isPrimary
                ? null
                : () => _write(
                    context,
                    () => context.read<VendorContactsCubit>().setPrimary(
                      id: contact.id,
                    ),
                  ),
          ),
          IconButton(
            key: ValueKey('contact-edit-${contact.id}'),
            icon: const Icon(Icons.edit_outlined),
            onPressed: isBusy
                ? null
                : () => context.push(
                    '/vendor/contacts/form',
                    extra: VendorContactFormArgs(
                      cubit: context.read<VendorContactsCubit>(),
                      contact: contact,
                    ),
                  ),
          ),
          IconButton(
            key: ValueKey('contact-delete-${contact.id}'),
            tooltip: l10n.deleteContact,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: isBusy ? null : () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<VendorContactsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.deleteContactQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const ValueKey('contact-delete-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteContact),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _write(context, () => cubit.remove(id: contact.id));
  }
}

/// Runs a write and hands the backend's own sentence to the snack bar when it
/// refuses; a write that worked has already re-read the groups.
Future<void> _write(
  BuildContext context,
  Future<String?> Function() write,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = await write();
  if (message == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class _ContactsMessage extends StatelessWidget {
  const _ContactsMessage({required this.message, this.action});

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

/// The picture each wire type is given; the labels come from the backend, so
/// only the icons are chosen here.
IconData contactTypeIcon(String type) => switch (type) {
  'phone' => Icons.call_rounded,
  'email' => Icons.alternate_email_rounded,
  'whatsapp' => Icons.chat_bubble_rounded,
  'telegram' => Icons.send_rounded,
  'instagram' => Icons.camera_alt_rounded,
  'facebook' => Icons.group_rounded,
  'twitter' => Icons.campaign_rounded,
  'tiktok' => Icons.music_note_rounded,
  'youtube' => Icons.smart_display_rounded,
  'snapchat' => Icons.snapchat,
  'linkedin' => Icons.work_rounded,
  'website' => Icons.language_rounded,
  _ => Icons.contact_page_rounded,
};

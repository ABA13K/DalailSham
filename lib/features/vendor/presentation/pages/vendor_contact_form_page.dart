import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/option_sheet.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/widgets/auth_widgets.dart';
import '../../domain/entities/contact_type.dart';
import '../../domain/entities/vendor_contact.dart';
import '../../domain/entities/vendor_contact_edit.dart';
import '../../domain/repositories/vendor_contact_repository.dart';
import '../cubit/vendor_contacts_cubit.dart';
import 'vendor_contacts_page.dart' show contactTypeIcon;

/// What the form route is handed: the cubit it writes through, and the line it
/// edits — none when the vendor is adding a contact.
///
/// Sharing the cubit is what keeps the list behind the form honest, since every
/// write reads the groups back into it.
class VendorContactFormArgs {
  const VendorContactFormArgs({required this.cubit, this.contact});

  final VendorContactsCubit cubit;
  final VendorContact? contact;
}

/// `POST /vendor/contacts` and `PUT /vendor/contacts/{id}` — the two fields both
/// take are the type token and the value.
class VendorContactFormPage extends StatefulWidget {
  const VendorContactFormPage({super.key, required this.args});

  final VendorContactFormArgs args;

  @override
  State<VendorContactFormPage> createState() => _VendorContactFormPageState();
}

class _VendorContactFormPageState extends State<VendorContactFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _value = TextEditingController(
    text: widget.args.contact?.value ?? '',
  );

  String? _type;
  String? _typeLabel;

  @override
  void initState() {
    super.initState();
    _type = widget.args.contact?.type;
    _typeLabel = widget.args.contact?.typeLabel;
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  Future<void> _pickType() async {
    final l10n = AppLocalizations.of(context);
    final type = await showOptionSheet<ContactType>(
      context,
      title: l10n.chooseContactType,
      label: (type) => type.label,
      load: _loadTypes,
    );
    if (type == null || !mounted) return;
    setState(() {
      _type = type.value;
      _typeLabel = type.label;
    });
  }

  /// The types endpoint takes no search, so the box the sheet offers filters
  /// the list it answered with instead of asking again.
  Future<List<ContactType>> _loadTypes(String locale, String? query) async {
    final result = await getIt<VendorContactRepository>().types(locale: locale);
    return result.fold((failure) => throw failure, (types) {
      final text = query?.trim().toLowerCase();
      if (text == null || text.isEmpty) return types;
      return [
        for (final type in types)
          if (type.label.toLowerCase().contains(text)) type,
      ];
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = widget.args.cubit;
    final contact = widget.args.contact;
    void notify(String message) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final type = _type;
    if (type == null) {
      notify(l10n.contactTypeRequired);
      return;
    }

    final edit = VendorContactEdit(type: type, value: _value.text.trim());
    final message = contact == null
        ? await cubit.add(edit)
        : await cubit.update(id: contact.id, edit: edit);
    if (message != null) {
      notify(message);
      return;
    }
    if (!mounted) return;

    notify(l10n.contactSaved);
    GoRouter.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: widget.args.cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.args.contact == null ? l10n.addContact : l10n.editContact,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    key: const ValueKey('contact-type-tile'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _type == null
                          ? Icons.category_rounded
                          : contactTypeIcon(_type!),
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      _typeLabel ?? l10n.labelContactType,
                      style: _typeLabel == null
                          ? theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            )
                          : null,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _pickType,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    key: const ValueKey('contact-value-field'),
                    controller: _value,
                    label: l10n.labelContactValue,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? l10n.contactValueRequired
                        : null,
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<VendorContactsCubit, VendorContactsState>(
                    builder: (context, state) => FilledButton(
                      key: const ValueKey('contact-save'),
                      onPressed: state.isSaving ? null : _submit,
                      child: state.isSaving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.saveContact),
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

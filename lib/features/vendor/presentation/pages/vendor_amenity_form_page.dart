import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/centered_content.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/widgets/auth_widgets.dart';
import '../../domain/entities/vendor_amenity.dart';
import '../../domain/entities/vendor_amenity_edit.dart';
import '../cubit/vendor_amenities_cubit.dart';

/// What the form route is handed: the cubit it writes through, and the amenity
/// it edits — none when the vendor is adding one.
///
/// Sharing the cubit is what keeps the list behind the form honest, since every
/// write reads the gallery back into it.
class VendorAmenityFormArgs {
  const VendorAmenityFormArgs({required this.cubit, this.amenity});

  final VendorAmenitiesCubit cubit;
  final VendorAmenity? amenity;
}

/// `POST /vendor/amenities` and `PUT /vendor/amenities/{id}` — the two names
/// both take. Whatever is written waits for an admin again.
class VendorAmenityFormPage extends StatefulWidget {
  const VendorAmenityFormPage({super.key, required this.args});

  final VendorAmenityFormArgs args;

  @override
  State<VendorAmenityFormPage> createState() => _VendorAmenityFormPageState();
}

class _VendorAmenityFormPageState extends State<VendorAmenityFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameAr = TextEditingController(
    text: widget.args.amenity?.nameAr ?? '',
  );
  late final TextEditingController _nameEn = TextEditingController(
    text: widget.args.amenity?.nameEn ?? '',
  );

  @override
  void dispose() {
    _nameAr.dispose();
    _nameEn.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = widget.args.cubit;
    final amenity = widget.args.amenity;
    void notify(String message) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final english = _nameEn.text.trim();
    final edit = VendorAmenityEdit(
      nameAr: _nameAr.text.trim(),
      nameEn: english.isEmpty ? null : english,
    );

    final message = amenity == null
        ? await cubit.add(edit)
        : await cubit.update(id: amenity.id, edit: edit);
    if (message != null) {
      notify(message);
      return;
    }
    notify(l10n.amenitySaved);
    if (!mounted) return;
    GoRouter.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = widget.args.cubit;
    final amenity = widget.args.amenity;
    if (amenity == null) return;
    void notify(String message) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.deleteAmenityQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const ValueKey('amenity-delete-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteAmenity),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final message = await cubit.remove(id: amenity.id);
    if (message != null) {
      notify(message);
      return;
    }
    notify(l10n.amenityDeleted);
    if (!mounted) return;
    GoRouter.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEdit = widget.args.amenity != null;

    String? checkName(String? value) {
      final required = value == null || value.trim().isEmpty
          ? l10n.fieldRequired
          : null;
      if (required != null) return required;
      return value!.length > 255 ? l10n.tooLong : null;
    }

    return BlocProvider.value(
      value: widget.args.cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEdit ? l10n.editAmenity : l10n.addAmenity,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            if (isEdit)
              IconButton(
                key: const ValueKey('amenity-delete'),
                tooltip: l10n.deleteAmenity,
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: _confirmDelete,
              ),
          ],
        ),
        body: CenteredContent(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.amenityWaitsForApproval,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    key: const ValueKey('amenity-name-ar'),
                    controller: _nameAr,
                    label: l10n.nameArabicLabel,
                    validator: checkName,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    key: const ValueKey('amenity-name-en'),
                    controller: _nameEn,
                    label: l10n.nameEnglishLabel,
                    validator: (value) =>
                        (value?.length ?? 0) > 255 ? l10n.tooLong : null,
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<VendorAmenitiesCubit, VendorAmenitiesState>(
                    builder: (context, state) => FilledButton(
                      key: const ValueKey('amenity-save'),
                      onPressed: state.isBusy ? null : _submit,
                      child: state.isBusy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEdit ? l10n.saveChanges : l10n.addAmenity),
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

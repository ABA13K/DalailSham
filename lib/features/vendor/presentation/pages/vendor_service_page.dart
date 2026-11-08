import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/centered_content.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/widgets/auth_widgets.dart';
import '../../domain/entities/vendor_service.dart';
import '../../domain/entities/vendor_service_edit.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../cubit/vendor_cubit.dart';

/// The signed-in vendor's own service: its cover picture, the nine fields
/// `PUT /vendor/service` edits and the password that opens the account.
class VendorServicePage extends StatelessWidget {
  const VendorServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return BlocProvider(
      create: (context) => VendorCubit(getIt<VendorRepository>())..load(locale),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.vendorServiceTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: CenteredContent(
          child: BlocBuilder<VendorCubit, VendorState>(
            builder: (context, state) => switch (state.status) {
              VendorStatus.initial || VendorStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              VendorStatus.failure => _VendorMessage(
                message: l10n.placesError,
                action: FilledButton.icon(
                  key: const ValueKey('vendor-retry'),
                  onPressed: () => context.read<VendorCubit>().load(
                    Localizations.localeOf(context).languageCode,
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              ),
              VendorStatus.ready => _VendorBody(service: state.service!),
            },
          ),
        ),
      ),
    );
  }
}

class _VendorBody extends StatelessWidget {
  const _VendorBody({required this.service});

  final VendorService service;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<VendorCubit, VendorState>(
      builder: (context, state) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CoverBlock(service: service, isBusy: state.isEditingImage),
            const SizedBox(height: 12),
            _FactsRow(service: service),
            if (service.regionName != null || service.categoryName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  [
                    if (service.regionName != null) service.regionName,
                    if (service.categoryName != null) service.categoryName,
                  ].whereType<String>().join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            _EditForm(service: service, isSaving: state.isSaving),
            const SizedBox(height: 8),
            ListTile(
              key: const ValueKey('vendor-password-tile'),
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.lock_reset_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(l10n.changePasswordTitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/vendor/service/password'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The cover picture and the one thing the vendor endpoints do to it: remove
/// it. Uploading a new one stays on the web dashboard for now.
class _CoverBlock extends StatelessWidget {
  const _CoverBlock({required this.service, required this.isBusy});

  final VendorService service;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 150,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: service.mainImage == null
                ? ColoredBox(
                    color: theme.colorScheme.primaryContainer,
                    child: Center(
                      child: Icon(
                        Icons.storefront_rounded,
                        size: 48,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        service.mainImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.broken_image_rounded,
                          size: 48,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      if (isBusy)
                        const ColoredBox(
                          color: Color(0x66000000),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
          ),
        ),
        if (service.mainImage != null) ...[
          const SizedBox(height: 6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              key: const ValueKey('vendor-remove-image'),
              onPressed: isBusy ? null : () => _removeImage(context),
              child: Text(l10n.removeMainImage),
            ),
          ),
        ],
      ],
    );
  }

  void _removeImage(BuildContext context) {
    final cubit = context.read<VendorCubit>();
    final messenger = ScaffoldMessenger.of(context);
    cubit.removeMainImage().then((message) {
      if (message == null) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    });
  }
}

/// The numbers the vendor does not edit: rating, reviews, visits, plan.
class _FactsRow extends StatelessWidget {
  const _FactsRow({required this.service});

  final VendorService service;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final facts = <(String, String)>[
      (l10n.labelRating, service.rating.toStringAsFixed(1)),
      (l10n.labelReviews, '${service.reviewsCount}'),
      (l10n.labelVisits, '${service.visitsCount}'),
      (l10n.labelPlan, service.subscriptionType ?? l10n.valueUnknown),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (label, value) in facts)
          _FactChip(label: label, value: value),
        if (service.isMain)
          _FactChip(label: l10n.labelFlag, value: l10n.mainServiceFlag),
      ],
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}

/// `PUT /vendor/service` — the nine fields it takes, nothing else.
class _EditForm extends StatefulWidget {
  const _EditForm({required this.service, required this.isSaving});

  final VendorService service;
  final bool isSaving;

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameAr = _controller(widget.service.nameAr);
  late final TextEditingController _nameEn = _controller(widget.service.nameEn);
  late final TextEditingController _addressAr = _controller(
    widget.service.addressAr,
  );
  late final TextEditingController _addressEn = _controller(
    widget.service.addressEn,
  );
  late final TextEditingController _mapsUrl = _controller(
    widget.service.googleMapsUrl,
  );
  late final TextEditingController _lat = _controller(
    widget.service.lat?.toString(),
  );
  late final TextEditingController _lng = _controller(
    widget.service.lng?.toString(),
  );
  late final TextEditingController _descriptionAr = _controller(
    widget.service.descriptionAr,
  );
  late final TextEditingController _descriptionEn = _controller(
    widget.service.descriptionEn,
  );

  TextEditingController _controller(String? text) =>
      TextEditingController(text: text ?? '');

  @override
  void dispose() {
    for (final controller in [
      _nameAr,
      _nameEn,
      _addressAr,
      _addressEn,
      _mapsUrl,
      _lat,
      _lng,
      _descriptionAr,
      _descriptionEn,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    context
        .read<VendorCubit>()
        .save(
          VendorServiceEdit(
            nameAr: _nameAr.text.trim(),
            nameEn: _nameEn.text.trim(),
            addressAr: _blank(_addressAr.text),
            addressEn: _blank(_addressEn.text),
            googleMapsUrl: _blank(_mapsUrl.text),
            lat: _coord(_lat.text),
            lng: _coord(_lng.text),
            descriptionAr: _blank(_descriptionAr.text),
            descriptionEn: _blank(_descriptionEn.text),
          ),
        )
        .then((message) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(message ?? l10n.vendorServiceSaved)),
            );
        });
  }

  static String? _blank(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static double? _coord(String value) => double.tryParse(value.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    String? checkRequired(String? value) =>
        value == null || value.trim().isEmpty ? l10n.fieldRequired : null;
    String? checkShort(String? value) =>
        (value?.length ?? 0) > 255 ? l10n.tooLong : null;
    String? checkLong(String? value) =>
        (value?.length ?? 0) > 5000 ? l10n.tooLong : null;
    String? checkUrl(String? value) {
      final text = _blank(value ?? '');
      if (text == null) return null;
      final uri = Uri.tryParse(text);
      return uri != null && (uri.isScheme('http') || uri.isScheme('https'))
          ? null
          : l10n.invalidUrl;
    }

    String? checkLatitude(String? value) =>
        _checkCoord(value, -90, 90, l10n.invalidLatitude);
    String? checkLongitude(String? value) =>
        _checkCoord(value, -180, 180, l10n.invalidLongitude);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            key: const ValueKey('vendor-name-ar'),
            controller: _nameAr,
            label: l10n.nameArabicLabel,
            validator: (value) => checkRequired(value) ?? checkShort(value),
          ),
          const SizedBox(height: 12),
          AuthTextField(
            key: const ValueKey('vendor-name-en'),
            controller: _nameEn,
            label: l10n.nameEnglishLabel,
            validator: (value) => checkRequired(value) ?? checkShort(value),
          ),
          const SizedBox(height: 12),
          AuthTextField(
            key: const ValueKey('vendor-address-ar'),
            controller: _addressAr,
            label: l10n.addressArabicLabel,
            validator: checkShort,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            key: const ValueKey('vendor-address-en'),
            controller: _addressEn,
            label: l10n.addressEnglishLabel,
            validator: checkShort,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            key: const ValueKey('vendor-maps-url'),
            controller: _mapsUrl,
            label: l10n.mapsUrlLabel,
            keyboardType: TextInputType.url,
            validator: checkUrl,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AuthTextField(
                  key: const ValueKey('vendor-lat'),
                  controller: _lat,
                  label: l10n.latitudeLabel,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  validator: checkLatitude,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AuthTextField(
                  key: const ValueKey('vendor-lng'),
                  controller: _lng,
                  label: l10n.longitudeLabel,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  validator: checkLongitude,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AuthTextField(
            key: const ValueKey('vendor-description-ar'),
            controller: _descriptionAr,
            label: l10n.descriptionArabicLabel,
            maxLines: 4,
            validator: checkLong,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            key: const ValueKey('vendor-description-en'),
            controller: _descriptionEn,
            label: l10n.descriptionEnglishLabel,
            maxLines: 4,
            validator: checkLong,
          ),
          const SizedBox(height: 20),
          FilledButton(
            key: const ValueKey('vendor-save'),
            onPressed: widget.isSaving ? null : _save,
            child: widget.isSaving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.saveChanges),
          ),
        ],
      ),
    );
  }

  /// An empty box means `null` to the endpoint, so only a typed coordinate has
  /// to be a number inside the range the validation rules allow.
  static String? _checkCoord(
    String? value,
    double min,
    double max,
    String message,
  ) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text);
    return parsed == null || parsed < min || parsed > max ? message : null;
  }
}

class _VendorMessage extends StatelessWidget {
  const _VendorMessage({required this.message, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}

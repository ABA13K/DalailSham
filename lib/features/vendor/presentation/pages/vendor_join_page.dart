import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/settings/presentation/locale_cubit.dart';
import '../../../../core/widgets/centered_content.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/auth_widgets.dart';
import '../../../categories/domain/entities/explore_category.dart';
import '../../../auth/domain/entities/join_request.dart';
import '../../../auth/domain/entities/registration.dart';
import '../../../profile/domain/entities/avatar_file.dart';
import '../../../profile/domain/repositories/avatar_picker.dart';
import '../../../regions/domain/entities/region.dart';
import '../../domain/repositories/vendor_picker_repository.dart';
import '../../../../core/widgets/option_sheet.dart';

/// `POST /vendor/join-request` — one form asking for both the account and the
/// service it wants listed, so an applicant never registers first.
///
/// The reply carries a bearer token, which [AuthCubit] stores: the applicant is
/// signed in while the service still waits for the admin review.
class VendorJoinPage extends StatefulWidget {
  const VendorJoinPage({super.key});

  @override
  State<VendorJoinPage> createState() => _VendorJoinPageState();
}

class _VendorJoinPageState extends State<VendorJoinPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  final TextEditingController _nameAr = TextEditingController();
  final TextEditingController _nameEn = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _companyEmail = TextEditingController();
  final TextEditingController _addressAr = TextEditingController();
  final TextEditingController _addressEn = TextEditingController();
  final TextEditingController _descriptionAr = TextEditingController();
  final TextEditingController _descriptionEn = TextEditingController();

  AuthGender? _gender;
  int? _regionId;
  String? _regionName;
  int? _categoryId;
  String? _categoryName;
  AvatarFile? _cover;

  @override
  void dispose() {
    for (final controller in [
      _fullName,
      _mobile,
      _email,
      _password,
      _confirm,
      _nameAr,
      _nameEn,
      _phone,
      _companyEmail,
      _addressAr,
      _addressEn,
      _descriptionAr,
      _descriptionEn,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    void notify(String message) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    // The three choices a text field cannot express, checked the same way the
    // register form checks gender.
    final gender = _gender;
    if (gender == null) {
      notify(l10n.genderRequired);
      return;
    }
    final regionId = _regionId;
    if (regionId == null) {
      notify(l10n.regionRequired);
      return;
    }
    final categoryId = _categoryId;
    if (categoryId == null) {
      notify(l10n.categoryRequired);
      return;
    }

    final auth = context.read<AuthCubit>();
    final localeCubit = context.read<LocaleCubit>();
    final router = GoRouter.of(context);

    final message = await auth.joinRequest(
      JoinRequest(
        fullName: _fullName.text.trim(),
        mobile: _mobile.text.trim(),
        password: _password.text,
        gender: gender,
        regionId: regionId,
        categoryId: categoryId,
        nameAr: _nameAr.text.trim(),
        nameEn: _nameEn.text.trim(),
        email: _optional(_email.text),
        phone: _optional(_phone.text),
        companyEmail: _optional(_companyEmail.text),
        addressAr: _optional(_addressAr.text),
        addressEn: _optional(_addressEn.text),
        descriptionAr: _optional(_descriptionAr.text),
        descriptionEn: _optional(_descriptionEn.text),
        mainImage: _cover,
      ),
    );
    if (!mounted) return;

    if (message != null) {
      notify(message);
      return;
    }

    final accountLocale = auth.state.user?.locale;
    if (accountLocale != null) await localeCubit.apply(accountLocale);
    notify(l10n.joinRequestSubmitted);

    // The applicant is signed in by this point and the service is still under
    // review, so the stack behind the form — the register page it was opened
    // from — has nothing left to show. Restart on home instead.
    router.go('/');
  }

  static String? _optional(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _pickRegion() async {
    final l10n = AppLocalizations.of(context);
    final region = await showOptionSheet<Region>(
      context,
      title: l10n.chooseRegion,
      label: (region) => region.name,
      load: _loadRegions,
    );
    if (region == null || !mounted) return;
    setState(() {
      _regionId = region.id;
      _regionName = region.name;
    });
  }

  Future<void> _pickCategory() async {
    final l10n = AppLocalizations.of(context);
    final category = await showOptionSheet<ExploreCategory>(
      context,
      title: l10n.chooseCategory,
      label: (category) => category.name,
      load: _loadCategories,
    );
    if (category == null || !mounted) return;
    setState(() {
      _categoryId = category.id;
      _categoryName = category.name;
    });
  }

  /// The sheet shows its own error row when a list cannot be read, so a failure
  /// travels as a throw rather than an empty result it would call "no matches".
  Future<List<Region>> _loadRegions(String locale, String? query) async {
    final result = await getIt<VendorPickerRepository>().regions(
      locale: locale,
      query: query,
    );
    return result.fold((failure) => throw failure, (regions) => regions);
  }

  Future<List<ExploreCategory>> _loadCategories(
    String locale,
    String? query,
  ) async {
    final result = await getIt<VendorPickerRepository>().categories(
      locale: locale,
      query: query,
    );
    return result.fold((failure) => throw failure, (categories) => categories);
  }

  Future<void> _pickCover() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    AvatarFile? picked;
    try {
      picked = await getIt<AvatarPicker>().pick();
    } catch (_) {
      picked = null;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.photoPickFailed)));
    }
    if (picked == null || !mounted) return;
    setState(() => _cover = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    String? checkRequired(String? value) =>
        value == null || value.trim().isEmpty ? l10n.fieldRequired : null;
    String? checkPassword(String? value) {
      if (value == null || value.isEmpty) return l10n.fieldRequired;
      if (value.length < 6) return l10n.passwordTooShort;
      return null;
    }

    String? checkConfirmation(String? value) =>
        value == _password.text ? null : l10n.passwordMismatch;
    String? checkShort(String? value) =>
        value != null && value.trim().length > 255 ? l10n.tooLong : null;
    String? checkLong(String? value) =>
        value != null && value.trim().length > 5000 ? l10n.tooLong : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.vendorJoinTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
                  l10n.joinIntro,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: l10n.joinAccountSection),
                AuthTextField(
                  key: const ValueKey('join-full-name'),
                  controller: _fullName,
                  label: l10n.fullNameLabel,
                  validator: checkRequired,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('join-mobile'),
                  controller: _mobile,
                  label: l10n.mobileLabel,
                  keyboardType: TextInputType.phone,
                  validator: checkRequired,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('join-email'),
                  controller: _email,
                  label: l10n.emailLabel,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('join-password'),
                  controller: _password,
                  label: l10n.passwordLabel,
                  obscure: true,
                  validator: checkPassword,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('join-confirm'),
                  controller: _confirm,
                  label: l10n.confirmPasswordLabel,
                  obscure: true,
                  validator: checkConfirmation,
                ),
                const SizedBox(height: 16),
                Text(l10n.genderLabel, style: theme.textTheme.labelLarge),
                const SizedBox(height: 6),
                SegmentedButton<AuthGender>(
                  key: const ValueKey('join-gender'),
                  segments: [
                    ButtonSegment(
                      value: AuthGender.male,
                      label: Text(l10n.genderMale),
                    ),
                    ButtonSegment(
                      value: AuthGender.female,
                      label: Text(l10n.genderFemale),
                    ),
                  ],
                  selected: _gender == null ? const {} : {_gender!},
                  emptySelectionAllowed: true,
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) {
                    if (selection.isEmpty) return;
                    setState(() => _gender = selection.first);
                  },
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: l10n.joinServiceSection),
                _CoverField(
                  cover: _cover,
                  onPick: _pickCover,
                  onRemove: () => setState(() => _cover = null),
                ),
                const SizedBox(height: 8),
                _ChoiceTile(
                  key: const ValueKey('join-region-tile'),
                  label: l10n.labelRegion,
                  placeholder: l10n.chooseRegion,
                  value: _regionName,
                  onTap: _pickRegion,
                ),
                _ChoiceTile(
                  key: const ValueKey('join-category-tile'),
                  label: l10n.labelCategory,
                  placeholder: l10n.chooseCategory,
                  value: _categoryName,
                  onTap: _pickCategory,
                ),
                const SizedBox(height: 8),
                AuthTextField(
                  key: const ValueKey('join-name-ar'),
                  controller: _nameAr,
                  label: l10n.nameArabicLabel,
                  validator: (value) =>
                      checkRequired(value) ?? checkShort(value),
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('join-name-en'),
                  controller: _nameEn,
                  label: l10n.nameEnglishLabel,
                  validator: (value) =>
                      checkRequired(value) ?? checkShort(value),
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('join-phone'),
                  controller: _phone,
                  label: l10n.labelPhone,
                  keyboardType: TextInputType.phone,
                  validator: checkShort,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('join-company-email'),
                  controller: _companyEmail,
                  label: l10n.companyEmailLabel,
                  keyboardType: TextInputType.emailAddress,
                  validator: checkShort,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('join-address-ar'),
                  controller: _addressAr,
                  label: l10n.addressArabicLabel,
                  validator: checkShort,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('join-address-en'),
                  controller: _addressEn,
                  label: l10n.addressEnglishLabel,
                  validator: checkShort,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('join-description-ar'),
                  controller: _descriptionAr,
                  label: l10n.descriptionArabicLabel,
                  maxLines: 4,
                  validator: checkLong,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('join-description-en'),
                  controller: _descriptionEn,
                  label: l10n.descriptionEnglishLabel,
                  maxLines: 4,
                  validator: checkLong,
                ),
                const SizedBox(height: 20),
                AuthSubmitButton(
                  key: const ValueKey('join-submit'),
                  label: l10n.sendRequest,
                  onTap: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// The optional cover picture; picked from the gallery and sent as
/// `main_image` with the rest of the application.
class _CoverField extends StatelessWidget {
  const _CoverField({
    required this.cover,
    required this.onPick,
    required this.onRemove,
  });

  final AvatarFile? cover;
  final Future<void> Function() onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final image = cover;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          key: const ValueKey('join-cover-tile'),
          borderRadius: BorderRadius.circular(14),
          onTap: image == null ? onPick : null,
          child: SizedBox(
            height: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: image == null
                  ? ColoredBox(
                      color: theme.colorScheme.primaryContainer,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 40,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.addCoverPhoto,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Image.memory(
                      image.bytes,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Icon(
                        Icons.broken_image_rounded,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
            ),
          ),
        ),
        if (image != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const ValueKey('join-remove-cover'),
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 18),
              label: Text(l10n.removePhoto),
            ),
          ),
      ],
    );
  }
}

/// Read-only row that opens one of the two vendor pick lists.
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    super.key,
    required this.label,
    required this.placeholder,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String placeholder;
  final String? value;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chosen = value;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(Icons.explore_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.labelLarge),
                  Text(
                    chosen ?? placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: chosen == null
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

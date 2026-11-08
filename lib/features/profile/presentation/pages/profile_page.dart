import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/centered_content.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/domain/entities/registration.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/auth_widgets.dart';
import '../../domain/entities/profile_edit.dart';
import '../../domain/repositories/avatar_picker.dart';
import '../../domain/repositories/profile_repository.dart';
import '../cubit/profile_cubit.dart';

/// The signed-in account: its picture, the three fields the backend edits, the
/// password it logs in with and the button that removes it for good.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return BlocProvider(
      create: (context) => ProfileCubit(
        getIt<ProfileRepository>(),
        getIt<AvatarPicker>(),
        context.read<AuthCubit>(),
      )..load(locale),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.accountProfileTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: CenteredContent(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) => switch (state.status) {
              ProfileStatus.initial || ProfileStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              ProfileStatus.failure => _ProfileMessage(
                message: l10n.placesError,
                action: FilledButton.icon(
                  onPressed: () => context.read<ProfileCubit>().load(
                    Localizations.localeOf(context).languageCode,
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              ),
              ProfileStatus.ready => _ProfileBody(user: state.user!),
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AvatarBlock(user: user, isBusy: state.isEditingAvatar),
            const SizedBox(height: 20),
            _EditForm(user: user, isSaving: state.isSaving),
            const SizedBox(height: 8),
            ListTile(
              key: const ValueKey('profile-password-tile'),
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.lock_reset_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(l10n.changePasswordTitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/profile/password'),
            ),
            ListTile(
              key: const ValueKey('profile-delete-tile'),
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.delete_outline_rounded,
                color: theme.colorScheme.error,
              ),
              title: Text(
                l10n.deleteAccountTitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _confirmDeletion(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeletion(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    final deleted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) =>
          _DeleteAccountDialog(onConfirm: cubit.deleteAccount),
    );
    if (deleted != true) return;

    navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.accountDeleted)));
  }
}

/// The picture, with the two things the avatar endpoints do to it.
class _AvatarBlock extends StatelessWidget {
  const _AvatarBlock({required this.user, required this.isBusy});

  final AuthUser user;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cubit = context.read<ProfileCubit>();

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.square(
              dimension: 104,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer,
                ),
                child: user.avatar == null
                    ? Icon(
                        Icons.person_rounded,
                        size: 52,
                        color: theme.colorScheme.onPrimaryContainer,
                      )
                    : ClipOval(
                        child: Image.network(
                          user.avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.person_rounded,
                            size: 52,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
              ),
            ),
            if (isBusy)
              const SizedBox.square(
                dimension: 104,
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(user.fullName, style: theme.textTheme.titleMedium),
        if (user.contact.isNotEmpty)
          Text(
            user.contact,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            TextButton(
              key: const ValueKey('profile-change-photo'),
              onPressed: isBusy
                  ? null
                  : () => _run(context, cubit.pickAvatar(l10n.photoPickFailed)),
              child: Text(l10n.changePhoto),
            ),
            if (user.avatar != null)
              TextButton(
                key: const ValueKey('profile-remove-photo'),
                onPressed: isBusy
                    ? null
                    : () => _run(context, cubit.removeAvatar()),
                child: Text(l10n.removePhoto),
              ),
          ],
        ),
      ],
    );
  }

  void _run(BuildContext context, Future<String?> request) {
    final messenger = ScaffoldMessenger.of(context);
    request.then((message) {
      if (message == null) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    });
  }
}

/// `PUT /user/profile` — name, gender and address, the three the endpoint takes.
class _EditForm extends StatefulWidget {
  const _EditForm({required this.user, required this.isSaving});

  final AuthUser user;
  final bool isSaving;

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName = TextEditingController(
    text: widget.user.fullName,
  );
  late final TextEditingController _address = TextEditingController(
    text: widget.user.address ?? '',
  );
  late AuthGender? _gender = AuthGender.fromWire(widget.user.gender);

  @override
  void dispose() {
    _fullName.dispose();
    _address.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ProfileCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final text = _address.text.trim();

    cubit
        .save(
          ProfileEdit(
            fullName: _fullName.text.trim(),
            gender: _gender,
            address: text.isEmpty ? null : text,
          ),
        )
        .then((message) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(message ?? l10n.profileSaved)),
            );
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            key: const ValueKey('profile-name'),
            controller: _fullName,
            label: l10n.fullNameLabel,
            validator: (value) => value == null || value.trim().isEmpty
                ? l10n.fieldRequired
                : null,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            key: const ValueKey('profile-address'),
            controller: _address,
            label: l10n.addressLabel,
          ),
          const SizedBox(height: 16),
          Text(l10n.genderLabel, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          SegmentedButton<AuthGender>(
            key: const ValueKey('profile-gender'),
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
          FilledButton(
            key: const ValueKey('profile-save'),
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
}

/// Asks for the password once, then hands it to the endpoint that deletes the
/// account. A refusal — a wrong password, or a vendor still holding services —
/// is shown here so the dialog stays open for another try; a yes answer means
/// the caller can leave the profile behind.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.onConfirm});

  final Future<String?> Function(String password) onConfirm;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final TextEditingController _password = TextEditingController();
  bool _isWorking = false;

  @override
  void initState() {
    super.initState();
    _password.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _password.removeListener(_onTextChanged);
    _password.dispose();
    super.dispose();
  }

  // The endpoint takes the password, so the button stays shut until one is typed.
  void _onTextChanged() => setState(() {});

  Future<void> _confirm() async {
    setState(() => _isWorking = true);
    final message = await widget.onConfirm(_password.text);
    if (!mounted) return;
    if (message == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isWorking = false;
      _password.clear();
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.deleteAccountTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.deleteAccountWarning),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('delete-account-password'),
            controller: _password,
            obscureText: true,
            enabled: !_isWorking,
            decoration: InputDecoration(
              labelText: l10n.passwordLabel,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const ValueKey('delete-account-cancel'),
          onPressed: _isWorking ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const ValueKey('delete-account-confirm'),
          onPressed: _isWorking || _password.text.isEmpty ? null : _confirm,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          child: _isWorking
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.deleteAccountTitle),
        ),
      ],
    );
  }
}

class _ProfileMessage extends StatelessWidget {
  const _ProfileMessage({required this.message, this.action});

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

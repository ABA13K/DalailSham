import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/settings/presentation/locale_cubit.dart';
import '../../../../core/widgets/centered_content.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/registration.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_widgets.dart';

/// `POST /auth/register` — the fields the endpoint accepts, with `avatar` left
/// null until image uploads exist.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  final TextEditingController _address = TextEditingController();
  AuthGender? _gender;

  @override
  void dispose() {
    _fullName.dispose();
    _mobile.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final gender = _gender;
    if (gender == null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.genderRequired)));
      return;
    }

    final auth = context.read<AuthCubit>();
    final localeCubit = context.read<LocaleCubit>();
    final navigator = Navigator.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final message = await auth.register(
      Registration(
        fullName: _fullName.text.trim(),
        mobile: _mobile.text.trim(),
        password: _password.text,
        gender: gender,
        email: _optional(_email.text),
        address: _optional(_address.text),
        locale: locale,
      ),
    );
    if (!mounted) return;

    if (message != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    final accountLocale = auth.state.user?.locale;
    if (accountLocale != null) await localeCubit.apply(accountLocale);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.accountCreated)));
    if (navigator.canPop()) navigator.pop();
  }

  static String? _optional(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.registerTitle,
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
                AuthTextField(
                  key: const ValueKey('register-full-name'),
                  controller: _fullName,
                  label: l10n.fullNameLabel,
                  validator: checkRequired,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('register-mobile'),
                  controller: _mobile,
                  label: l10n.mobileLabel,
                  keyboardType: TextInputType.phone,
                  validator: checkRequired,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('register-email'),
                  controller: _email,
                  label: l10n.emailLabel,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('register-password'),
                  controller: _password,
                  label: l10n.passwordLabel,
                  obscure: true,
                  validator: checkPassword,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('register-confirm'),
                  controller: _confirm,
                  label: l10n.confirmPasswordLabel,
                  obscure: true,
                  validator: checkConfirmation,
                ),
                const SizedBox(height: 16),
                Text(l10n.genderLabel, style: theme.textTheme.labelLarge),
                const SizedBox(height: 6),
                SegmentedButton<AuthGender>(
                  key: const ValueKey('register-gender'),
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
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('register-address'),
                  controller: _address,
                  label: l10n.addressLabel,
                ),
                const SizedBox(height: 20),
                AuthSubmitButton(
                  key: const ValueKey('register-submit'),
                  label: l10n.registerTitle,
                  onTap: _submit,
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(l10n.haveAccount, style: theme.textTheme.bodySmall),
                    TextButton(
                      key: const ValueKey('open-login'),
                      onPressed: () => context.push('/login'),
                      child: Text(l10n.loginTitle),
                    ),
                  ],
                ),
                // A vendor account is not a flag on this form: it comes out of
                // the join request, which asks for the service as well.
                Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    key: const ValueKey('open-vendor-join'),
                    onPressed: () => context.push('/vendor/join-request'),
                    icon: const Icon(Icons.storefront_outlined, size: 18),
                    label: Text(l10n.vendorJoinTitle),
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

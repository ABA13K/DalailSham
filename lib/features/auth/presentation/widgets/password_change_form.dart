import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/password_change.dart';
import 'auth_widgets.dart';

/// The three fields both change-password endpoints take, in the one order they
/// validate them in: current password, new password, confirmation.
///
/// [onSubmit] answers with the message to show, or null when it worked — the
/// two endpoints reject a wrong current password with their own sentence, so
/// the backend's words are shown rather than re-derived here.
class PasswordChangeForm extends StatefulWidget {
  const PasswordChangeForm({super.key, required this.onSubmit});

  final Future<String?> Function(PasswordChange change) onSubmit;

  @override
  State<PasswordChangeForm> createState() => _PasswordChangeFormState();
}

class _PasswordChangeFormState extends State<PasswordChangeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _current = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmation = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    setState(() => _isSubmitting = true);
    final message = await widget.onSubmit(
      PasswordChange(
        currentPassword: _current.text,
        password: _password.text,
        confirmation: _confirmation.text,
      ),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    messenger.hideCurrentSnackBar();
    if (message != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    messenger.showSnackBar(SnackBar(content: Text(l10n.passwordChanged)));
    if (navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String? checkRequired(String? value) =>
        value == null || value.isEmpty ? l10n.fieldRequired : null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            key: const ValueKey('current-password-field'),
            controller: _current,
            label: l10n.currentPasswordLabel,
            obscure: true,
            validator: checkRequired,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            key: const ValueKey('new-password-field'),
            controller: _password,
            label: l10n.newPasswordLabel,
            obscure: true,
            validator: (value) {
              final required = checkRequired(value);
              if (required != null) return required;
              return value!.length < 6 ? l10n.passwordTooShort : null;
            },
          ),
          const SizedBox(height: 12),
          AuthTextField(
            key: const ValueKey('confirm-password-field'),
            controller: _confirmation,
            label: l10n.confirmPasswordLabel,
            obscure: true,
            validator: (value) {
              final required = checkRequired(value);
              if (required != null) return required;
              return value != _password.text ? l10n.passwordMismatch : null;
            },
          ),
          const SizedBox(height: 20),
          FilledButton(
            key: const ValueKey('password-submit'),
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.changePasswordTitle),
          ),
        ],
      ),
    );
  }
}

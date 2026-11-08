import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/settings/presentation/locale_cubit.dart';
import '../../../../core/widgets/centered_content.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/credentials.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_widgets.dart';

/// `POST /auth/login` — the identifier is either the email or the mobile.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _login = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthCubit>();
    final localeCubit = context.read<LocaleCubit>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    final message = await auth.login(
      Credentials(login: _login.text.trim(), password: _password.text),
    );
    if (!mounted) return;

    if (message != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    final locale = auth.state.user?.locale;
    if (locale != null) await localeCubit.apply(locale);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.loggedIn)));
    if (navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String? checkRequired(String? value) =>
        value == null || value.trim().isEmpty ? l10n.fieldRequired : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.loginTitle,
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
                  key: const ValueKey('login-field'),
                  controller: _login,
                  label: l10n.loginFieldLabel,
                  keyboardType: TextInputType.emailAddress,
                  validator: checkRequired,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  key: const ValueKey('password-field'),
                  controller: _password,
                  label: l10n.passwordLabel,
                  obscure: true,
                  validator: checkRequired,
                ),
                const SizedBox(height: 20),
                AuthSubmitButton(
                  key: const ValueKey('login-submit'),
                  label: l10n.signIn,
                  onTap: _submit,
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.noAccount,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    TextButton(
                      key: const ValueKey('open-register'),
                      onPressed: () => context.push('/register'),
                      child: Text(l10n.registerTitle),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

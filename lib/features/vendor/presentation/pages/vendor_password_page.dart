import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/centered_content.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/widgets/password_change_form.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../cubit/vendor_cubit.dart';

/// `POST /vendor/service/account/change-password`.
///
/// A wrong current password is a 422 carrying its own sentence, so the
/// backend's words are shown rather than re-derived here.
class VendorPasswordPage extends StatelessWidget {
  const VendorPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) => VendorCubit(getIt<VendorRepository>()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.changePasswordTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: CenteredContent(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: PasswordChangeForm(
                onSubmit: context.read<VendorCubit>().changePassword,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/centered_content.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/password_change_form.dart';
import '../../domain/repositories/avatar_picker.dart';
import '../../domain/repositories/profile_repository.dart';
import '../cubit/profile_cubit.dart';

/// `POST /user/profile/change-password`.
class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) => ProfileCubit(
        getIt<ProfileRepository>(),
        getIt<AvatarPicker>(),
        context.read<AuthCubit>(),
      ),
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
                onSubmit: context.read<ProfileCubit>().changePassword,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/locale_repository.dart';

/// Holds the current app locale and persists changes.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._repository) : super(const Locale('ar'));

  final LocaleRepository _repository;

  Future<void> load() async {
    final code = await _repository.getLocaleCode();
    emit(Locale(code ?? 'ar'));
  }

  Future<void> toggle() async =>
      apply(state.languageCode == 'ar' ? 'en' : 'ar');

  /// Switches to [code] — the drawer's language row and the language an
  /// account was created with both land here.
  Future<void> apply(String code) async {
    if (code == state.languageCode) return;
    emit(Locale(code));
    await _repository.saveLocaleCode(code);
  }
}

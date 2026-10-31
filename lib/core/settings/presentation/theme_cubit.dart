import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/theme_repository.dart';

/// Holds the current theme mode and persists explicit light/dark choices.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._repository) : super(ThemeMode.system);

  final ThemeRepository _repository;

  Future<void> load() async {
    final mode = await _repository.getThemeMode();
    emit(switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    });
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == state) return;
    emit(mode);
    await _repository.saveThemeMode(mode.name);
  }
}

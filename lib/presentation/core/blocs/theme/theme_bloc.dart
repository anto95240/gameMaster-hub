import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object> get props => [];
}

class ToggleTheme extends ThemeEvent {}
class LoadTheme extends ThemeEvent {}

// States
class ThemeState extends Equatable {
  final bool isDarkMode;
  const ThemeState({required this.isDarkMode});

  @override
  List<Object> get props => [isDarkMode];
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final Box _box = Hive.box('theme_box');

  ThemeBloc() : super(const ThemeState(isDarkMode: true)) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);

    add(LoadTheme());
  }

  void _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) {
    final isDarkMode = _box.get('is_dark_mode', defaultValue: true) as bool;
    emit(ThemeState(isDarkMode: isDarkMode));
  }

  Future<void> _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) async {
    final newMode = !state.isDarkMode;
    await _box.put('is_dark_mode', newMode);
    emit(ThemeState(isDarkMode: newMode));
  }
}

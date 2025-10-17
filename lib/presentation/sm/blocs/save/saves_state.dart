// lib/presentation/sm/blocs/save/saves_state.dart
import 'package:equatable/equatable.dart';
import '../../../../domain/core/entities/save.dart';

abstract class SavesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SavesInitial extends SavesState {}

class SavesLoading extends SavesState {}

class SavesLoaded extends SavesState {
  final List<Save> saves;
  SavesLoaded(this.saves);

  SavesLoaded copyWith({List<Save>? saves}) {
    return SavesLoaded(saves ?? this.saves);
  }

  @override
  List<Object?> get props => [saves];
}

class SavesError extends SavesState {
  final String message;
  SavesError(this.message);

  @override
  List<Object?> get props => [message];
}

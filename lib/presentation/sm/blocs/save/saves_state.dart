import 'package:equatable/equatable.dart';

import 'package:gamemaster_hub/domain/core/entities/save.dart';

abstract class SavesState extends Equatable {
  const SavesState();

  @override
  List<Object?> get props => [];
}

class SavesInitial extends SavesState {}

class SavesLoading extends SavesState {}

class SavesLoaded extends SavesState {
  final List<Save> saves;

  const SavesLoaded(this.saves);

  @override
  List<Object?> get props => [saves];
}

class SavesError extends SavesState {
  final String message;

  const SavesError(this.message);

  @override
  List<Object?> get props => [message];
}

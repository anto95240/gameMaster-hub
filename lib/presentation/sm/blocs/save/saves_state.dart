import 'package:equatable/equatable.dart';
import '../../../../domain/core/entities/save.dart';

abstract class SavesState extends Equatable {
  const SavesState();

  @override
  List<Object?> get props => [];
}

class SavesInitial extends SavesState {}

class SavesLoading extends SavesState {}

class SavesLoaded extends SavesState {
  final List<Save> saves;
  final int? selectedSaveId;

  const SavesLoaded(this.saves, {this.selectedSaveId});

  @override
  List<Object?> get props => [saves, selectedSaveId ?? 0];
}

class SavesError extends SavesState {
  final String message;

  const SavesError(this.message);

  @override
  List<Object?> get props => [message];
}

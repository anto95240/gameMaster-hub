import 'package:equatable/equatable.dart';

abstract class SavesEvent extends Equatable {
  const SavesEvent();
  @override
  List<Object?> get props => [];
}

class LoadSavesEvent extends SavesEvent {
  final int gameId;
  const LoadSavesEvent({required this.gameId});
  @override
  List<Object?> get props => [gameId];
}

class AddSaveEvent extends SavesEvent {
  final int gameId;
  final String userId;
  final String name;
  final String? description;

  const AddSaveEvent({
    required this.gameId,
    required this.userId,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [gameId, userId, name, description];
}

class UpdateSaveEvent extends SavesEvent {
  final int saveId;
  final int gameId;
  final String name;
  final String? description;

  const UpdateSaveEvent({
    required this.saveId,
    required this.gameId,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [saveId, gameId, name, description];
}

class DeleteSaveEvent extends SavesEvent {
  final int saveId;
  final int gameId;

  const DeleteSaveEvent({required this.saveId, required this.gameId});
  @override
  List<Object?> get props => [saveId, gameId];
}

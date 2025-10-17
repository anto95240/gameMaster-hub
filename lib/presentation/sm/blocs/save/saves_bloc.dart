// lib/presentation/sm/blocs/save/saves_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/core/repositories/save_repository.dart';
import 'saves_event.dart';
import 'saves_state.dart';

class SavesBloc extends Bloc<SavesEvent, SavesState> {
  final SaveRepository saveRepository;

  SavesBloc(this.saveRepository) : super(SavesInitial()) {
    on<LoadSavesEvent>(_onLoadSaves);
  }

  Future<void> _onLoadSaves(
      LoadSavesEvent event, Emitter<SavesState> emit) async {
    emit(SavesLoading());
    try {
      final saves = await saveRepository.getSavesByGame(event.gameId);
      emit(SavesLoaded(saves));
    } catch (e) {
      emit(SavesError(e.toString()));
    }
  }
}

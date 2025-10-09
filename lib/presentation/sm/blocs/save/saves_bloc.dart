import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/domain/core/entities/save.dart';
import 'package:gamemaster_hub/domain/core/repositories/save_repository.dart';
import 'saves_event.dart';
import 'saves_state.dart';
import '../../../../main.dart';

class SavesBloc extends Bloc<SavesEvent, SavesState> {
  final SaveRepository repository;

  SavesBloc({required this.repository}) : super(SavesLoading()) {
    on<LoadSavesEvent>((event, emit) async {
      emit(SavesLoading());
      try {
        final saves = await repository.getSavesByGame(event.gameId);
        int selectedId = saves.isNotEmpty ? saves.first.id : 0;
        emit(SavesLoaded(saves: saves, selectedSaveId: selectedId));
      } catch (e) {
        emit(SavesError(message: e.toString()));
      }
    });

    on<SelectSaveEvent>((event, emit) {
      if (state is SavesLoaded) {
        final currentState = state as SavesLoaded;
        emit(currentState.copyWith(selectedSaveId: event.saveId));
      }
    });
  }
}
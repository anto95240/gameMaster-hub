import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gamemaster_hub/domain/core/entities/save.dart';
import 'package:gamemaster_hub/domain/core/repositories/save_repository.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/save/saves_event.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/save/saves_state.dart';

class SavesBloc extends Bloc<SavesEvent, SavesState> {
  final SaveRepository saveRepository;

  SavesBloc({required this.saveRepository}) : super(SavesInitial()) {
    on<LoadSavesEvent>((event, emit) async {
      emit(SavesLoading());
      try {
        final saves = await saveRepository.getSavesByGame(event.gameId);
        final updatedSaves = await _computeStats(saves);
        saves.sort((a, b) => a.id.compareTo(b.id));
        emit(SavesLoaded(updatedSaves));
      } catch (e) {
        emit(SavesError(e.toString()));
      }
    });

    on<AddSaveEvent>((event, emit) async {
      try {
        final saveToCreate = Save(
          id: 0, // Supabase génère l'id automatiquement
          gameId: event.gameId,
          userId: event.userId,
          name: event.name,
          description: event.description ?? '',
          isActive: true,
        );

        await saveRepository.createSave(saveToCreate);
        final saves = await saveRepository.getSavesByGame(event.gameId);
        final updatedSaves = await _computeStats(saves);
        emit(SavesLoaded(updatedSaves));
      } catch (e) {
        emit(SavesError(e.toString()));
      }
    });

    on<UpdateSaveEvent>((event, emit) async {
      try {
        final existingSave = await saveRepository.getSaveById(event.saveId);
        if (existingSave == null) throw Exception("Sauvegarde introuvable");

        final updatedSave = existingSave.copyWith(
          name: event.name,
          description: event.description,
        );

        await saveRepository.updateSave(updatedSave);
        final saves = await saveRepository.getSavesByGame(event.gameId);
        final updatedSaves = await _computeStats(saves);
        emit(SavesLoaded(updatedSaves));
      } catch (e) {
        emit(SavesError(e.toString()));
      }
    });

    on<DeleteSaveEvent>((event, emit) async {
      try {
        await saveRepository.deleteSave(event.saveId);
        final saves = await saveRepository.getSavesByGame(event.gameId);
        final updatedSaves = await _computeStats(saves);
        emit(SavesLoaded(updatedSaves));
      } catch (e) {
        emit(SavesError(e.toString()));
      }
    });
  }

  /// 🧮 Calcule les stats à partir du repository
  Future<List<Save>> _computeStats(List<Save> saves) async {
    final List<Save> updated = [];
    for (final save in saves) {
      try {
        final count = await saveRepository.countPlayersBySave(save.id);
        final avg = await saveRepository.averageRatingBySave(save.id);

        updated.add(
          save.copyWith(
            numberOfPlayers: count,
            overallRating: avg.roundToDouble(), // arrondi sans décimale
          ),
        );
      } catch (_) {
        // En cas d'erreur, on garde la save telle quelle
        updated.add(save);
      }
    }
    return updated;
  }
}

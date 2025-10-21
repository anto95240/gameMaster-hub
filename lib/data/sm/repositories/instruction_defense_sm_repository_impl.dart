import 'package:gamemaster_hub/data/sm/datasources/instruction_defense_sm_remote_data_source.dart';
import 'package:gamemaster_hub/data/sm/models/instruction_defense_sm_model.dart';
import 'package:gamemaster_hub/domain/sm/entities/instruction_defense_sm.dart';
import 'package:gamemaster_hub/domain/sm/repositories/instruction_defense_sm_repository.dart';

class InstructionDefenseSmRepositoryImpl implements InstructionDefenseSmRepository {
  final InstructionDefenseSmRemoteDataSource remoteDataSource;

  InstructionDefenseSmRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<InstructionDefenseSm>> getAllInstructions(int saveId) async {
    return await remoteDataSource.fetchInstructions(saveId);
  }

  @override
  Future<InstructionDefenseSm?> getInstructionByTactiqueId(int tactiqueId, int saveId) async {
    final list = await remoteDataSource.fetchInstructions(saveId);
    return list.firstWhere(
      (i) => i.tactiqueId == tactiqueId,
      orElse: () => InstructionDefenseSmModel(
        id: -1,
        tactiqueId: tactiqueId,
        saveId: saveId,
        pressing: '',
        styleTacle: '',
        ligneDefensive: '',
        gardienLibero: '',
        perteTemps: '',
      ),
    );
  }

  @override
  Future<void> insertInstruction(InstructionDefenseSm instruction) async {
    await remoteDataSource.insertInstruction(instruction as InstructionDefenseSmModel);
  }

  @override
  Future<void> updateInstruction(InstructionDefenseSm instruction) async {
    await remoteDataSource.updateInstruction(instruction as InstructionDefenseSmModel);
  }

  @override
  Future<void> deleteInstruction(int id) async {
    await remoteDataSource.deleteInstruction(id);
  }
}

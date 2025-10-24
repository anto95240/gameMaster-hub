import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';

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

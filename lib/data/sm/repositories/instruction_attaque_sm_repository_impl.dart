import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';

class InstructionAttaqueSmRepositoryImpl implements InstructionAttaqueSmRepository {
  final InstructionAttaqueSmRemoteDataSource remoteDataSource;

  InstructionAttaqueSmRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<InstructionAttaqueSm>> getAllInstructions(int saveId) async {
    return await remoteDataSource.fetchInstructions(saveId);
  }

  @override
  Future<InstructionAttaqueSmModel> getInstructionByTactiqueId(int tactiqueId, int saveId) async {
    final list = await remoteDataSource.fetchInstructions(saveId);
    return list.firstWhere(
      (i) => i.tactiqueId == tactiqueId,
      orElse: () => InstructionAttaqueSmModel(
        id: -1,
        tactiqueId: tactiqueId,
        saveId: saveId,
        stylePasse: '',
        styleAttaque: '',
        attaquants: '',
        jeuLarge: '',
        jeuConstruction: '',
        contreAttaque: '',
      ),
    );
  }

  @override
  Future<void> insertInstruction(InstructionAttaqueSm instruction) async {
    await remoteDataSource.insertInstruction(instruction as InstructionAttaqueSmModel);
  }

  @override
  Future<void> updateInstruction(InstructionAttaqueSm instruction) async {
    await remoteDataSource.updateInstruction(instruction as InstructionAttaqueSmModel);
  }

  @override
  Future<void> deleteInstruction(int id) async {
    await remoteDataSource.deleteInstruction(id);
  }
}

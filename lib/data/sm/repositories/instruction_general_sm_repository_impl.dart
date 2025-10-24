import 'package:gamemaster_hub/data/data_export.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';

class InstructionGeneralSmRepositoryImpl implements InstructionGeneralSmRepository {
  final InstructionGeneralSmRemoteDataSource remoteDataSource;

  InstructionGeneralSmRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<InstructionGeneralSm>> getAllInstructions(int saveId) async {
    return await remoteDataSource.fetchInstructions(saveId);
  }

  @override
  Future<InstructionGeneralSmModel> getInstructionByTactiqueId(int tactiqueId, int saveId) async {
    final list = await remoteDataSource.fetchInstructions(saveId);
    return list.firstWhere(
      (i) => i.tactiqueId == tactiqueId,
      orElse: () => InstructionGeneralSmModel(
        id: -1,
        tactiqueId: tactiqueId,
        saveId: saveId,
        largeur: '',
        mentalite: '',
        tempo: '',
        fluidite: '',
        rythmeTravail: '',
        creativite: '',
      ),
    );
  }

  @override
  Future<void> insertInstruction(InstructionGeneralSm instruction) async {
    await remoteDataSource.insertInstruction(instruction as InstructionGeneralSmModel);
  }

  @override
  Future<void> updateInstruction(InstructionGeneralSm instruction) async {
    await remoteDataSource.updateInstruction(instruction as InstructionGeneralSmModel);
  }

  @override
  Future<void> deleteInstruction(int id) async {
    await remoteDataSource.deleteInstruction(id);
  }
}

import 'package:gamemaster_hub/domain/sm/entities/instruction_general_sm.dart';
import 'package:gamemaster_hub/domain/sm/repositories/instruction_general_sm_repository.dart';
import '../datasources/instruction_general_sm_remote_data_source.dart';
import '../models/instruction_general_sm_model.dart';

class InstructionGeneralSmRepositoryImpl implements InstructionGeneralSmRepository {
  final InstructionGeneralSmRemoteDataSource remoteDataSource;

  InstructionGeneralSmRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<InstructionGeneralSm>> getAllInstructions() async {
    return await remoteDataSource.fetchInstructions();
  }

  @override
  Future<InstructionGeneralSmModel> getInstructionByTactiqueId(int tactiqueId) async {
    final list = await remoteDataSource.fetchInstructions();
    return list.firstWhere(
      (i) => i.tactiqueId == tactiqueId,
      orElse: () => InstructionGeneralSmModel(
        id: -1,
        tactiqueId: tactiqueId,
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

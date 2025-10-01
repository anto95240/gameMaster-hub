import 'package:gamemaster_hub/domain/sm/entities/instruction_defense_sm.dart';
import 'package:gamemaster_hub/domain/sm/repositories/instruction_defense_sm_repository.dart';
import '../datasources/instruction_defense_sm_remote_data_source.dart';
import '../models/instruction_defense_sm_model.dart';

class InstructionDefenseSmRepositoryImpl implements InstructionDefenseSmRepository {
  final InstructionDefenseSmRemoteDataSource remoteDataSource;

  InstructionDefenseSmRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<InstructionDefenseSm>> getAllInstructions() async {
    return await remoteDataSource.fetchInstructions();
  }

  @override
  Future<InstructionDefenseSmModel> getInstructionByTactiqueId(int tactiqueId) async {
    final list = await remoteDataSource.fetchInstructions();
    return list.firstWhere(
      (i) => i.tactiqueId == tactiqueId,
      orElse: () => InstructionDefenseSmModel(
        id: -1,
        tactiqueId: tactiqueId,
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

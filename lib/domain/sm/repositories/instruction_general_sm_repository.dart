import 'package:gamemaster_hub/domain/domain_export.dart';

abstract class InstructionGeneralSmRepository {
  Future<List<InstructionGeneralSm>> getAllInstructions(int saveId);
  Future<InstructionGeneralSm?> getInstructionByTactiqueId(int tactiqueId, int saveId);
  Future<void> insertInstruction(InstructionGeneralSm instruction);
  Future<void> updateInstruction(InstructionGeneralSm instruction);
  Future<void> deleteInstruction(int id);
}

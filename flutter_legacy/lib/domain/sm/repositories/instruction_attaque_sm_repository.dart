import 'package:gamemaster_hub/domain/domain_export.dart';

abstract class InstructionAttaqueSmRepository {
  Future<List<InstructionAttaqueSm>> getAllInstructions(int saveId);
  Future<InstructionAttaqueSm?> getInstructionByTactiqueId(int tactiqueId, int saveId);
  Future<void> insertInstruction(InstructionAttaqueSm instruction);
  Future<void> updateInstruction(InstructionAttaqueSm instruction);
  Future<void> deleteInstruction(int id);
}

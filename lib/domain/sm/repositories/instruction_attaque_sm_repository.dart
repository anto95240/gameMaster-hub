import '../entities/instruction_attaque_sm.dart';

abstract class InstructionAttaqueSmRepository {
  Future<List<InstructionAttaqueSm>> getAllInstructions(int saveId);
  Future<InstructionAttaqueSm?> getInstructionByTactiqueId(int tactiqueId, int saveId);
  Future<void> insertInstruction(InstructionAttaqueSm instruction);
  Future<void> updateInstruction(InstructionAttaqueSm instruction);
  Future<void> deleteInstruction(int id);
}

import '../entities/instruction_defense_sm.dart';

abstract class InstructionDefenseSmRepository {
  Future<List<InstructionDefenseSm>> getAllInstructions(int saveId);
  Future<InstructionDefenseSm?> getInstructionByTactiqueId(int tactiqueId, int saveId);
  Future<void> insertInstruction(InstructionDefenseSm instruction);
  Future<void> updateInstruction(InstructionDefenseSm instruction);
  Future<void> deleteInstruction(int id);
}

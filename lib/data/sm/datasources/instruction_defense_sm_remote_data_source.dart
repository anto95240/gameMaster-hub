import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/instruction_defense_sm_model.dart';

class InstructionDefenseSmRemoteDataSource {
  final SupabaseClient supabase;

  InstructionDefenseSmRemoteDataSource(this.supabase);

  Future<List<InstructionDefenseSmModel>> fetchInstructions() async {
    final response = await supabase.from('instruction_defense_sm').select().execute();
    final data = response.data as List<dynamic>;
    return data.map((e) => InstructionDefenseSmModel.fromMap(e)).toList();
  }

  Future<void> insertInstruction(InstructionDefenseSmModel instruction) async {
    await supabase.from('instruction_defense_sm').insert(instruction.toMap()).execute();
  }

  Future<void> updateInstruction(InstructionDefenseSmModel instruction) async {
    await supabase.from('instruction_defense_sm')
        .update(instruction.toMap())
        .eq('id', instruction.id)
        .execute();
  }

  Future<void> deleteInstruction(int id) async {
    await supabase.from('instruction_defense_sm').delete().eq('id', id).execute();
  }
}

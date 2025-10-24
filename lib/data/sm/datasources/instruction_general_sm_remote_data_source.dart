import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gamemaster_hub/data/sm/models/instruction_general_sm_model.dart';

class InstructionGeneralSmRemoteDataSource {
  final SupabaseClient supabase;

  InstructionGeneralSmRemoteDataSource(this.supabase);

  Future<List<InstructionGeneralSmModel>> fetchInstructions(int saveId) async {
    final response = await supabase
        .from('instruction_general_sm')
        .select()
        .eq('save_id', saveId)
        . execute();
    final data = response.data as List<dynamic>;
    return data.map((e) => InstructionGeneralSmModel.fromMap(e)).toList();
  }

  Future<void> insertInstruction(InstructionGeneralSmModel instruction) async {
    await supabase.from('instruction_general_sm').insert(instruction.toMap()).execute();
  }

  Future<void> updateInstruction(InstructionGeneralSmModel instruction) async {
    await supabase.from('instruction_general_sm')
        .update(instruction.toMap())
        .eq('id', instruction.id)
        .execute();
  }

  Future<void> deleteInstruction(int id) async {
    await supabase.from('instruction_general_sm').delete().eq('id', id).execute();
  }
}

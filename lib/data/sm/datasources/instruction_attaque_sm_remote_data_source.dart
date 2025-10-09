import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/instruction_attaque_sm_model.dart';

class InstructionAttaqueSmRemoteDataSource {
  final SupabaseClient supabase;

  InstructionAttaqueSmRemoteDataSource(this.supabase);

  Future<List<InstructionAttaqueSmModel>> fetchInstructions(int saveId) async {
    final response = await supabase
        .from('instruction_attaque_sm')
        .select()
        .eq('save_id', saveId)
        .execute();

    final data = response.data as List<dynamic>;
    return data.map((e) => InstructionAttaqueSmModel.fromMap(e)).toList();
  }

  Future<void> insertInstruction(InstructionAttaqueSmModel instruction) async {
    await supabase
        .from('instruction_attaque_sm')
        .insert(instruction.toMap())
        .execute();
  }

  Future<void> updateInstruction(InstructionAttaqueSmModel instruction) async {
    await supabase
        .from('instruction_attaque_sm')
        .update(instruction.toMap())
        .eq('id', instruction.id)
        .execute();
  }

  Future<void> deleteInstruction(int id) async {
    await supabase.from('instruction_attaque_sm').delete().eq('id', id).execute();
  }
}

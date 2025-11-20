import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gamemaster_hub/data/data_export.dart';

class InstructionDefenseSmRemoteDataSource {
  final SupabaseClient supabase;

  InstructionDefenseSmRemoteDataSource(this.supabase);

  Future<List<InstructionDefenseSmModel>> fetchInstructions(int saveId) async {
    final response = await supabase
        .from('instruction_defense_sm')
        .select()
        .eq('save_id', saveId)
        .execute();

    final data = response.data as List<dynamic>;
    return data.map((e) => InstructionDefenseSmModel.fromMap(e)).toList();
  }

  Future<void> insertInstruction(InstructionDefenseSmModel instruction) async {
    final data = instruction.toMap()..remove('id');
    await supabase.from('instruction_defense_sm').insert(data).execute();
  }

  Future<void> updateInstruction(InstructionDefenseSmModel instruction) async {
    await supabase
        .from('instruction_defense_sm')
        .update(instruction.toMap())
        .eq('id', instruction.id)
        .execute();
  }

  Future<void> deleteInstruction(int id) async {
    await supabase.from('instruction_defense_sm').delete().eq('id', id).execute();
  }
}
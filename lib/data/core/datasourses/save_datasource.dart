import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/save_model.dart';

class SaveDatasource {
  final SupabaseClient supabase;

  SaveDatasource(this.supabase);

  // Récupérer toutes les saves d'un jeu
  Future<List<SaveModel>> getSavesByGame(String gameId) async {
    final userId = supabase.auth.currentUser?.id;
    final response = await supabase
        .from('save')
        .select()
        .eq('game_id', gameId)
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => SaveModel.fromMap(e)).toList();
  }

  // Récupérer une save par ID
  Future<SaveModel?> getSaveById(int saveId) async {
    final userId = supabase.auth.currentUser?.id;
    final response = await supabase
        .from('save')
        .select()
        .eq('id', saveId)
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) return null;
    return SaveModel.fromMap(response);
  }

  // Créer une save
  Future<int> createSave(SaveModel save) async {
    final data = save.toMap();
    final response = await supabase.from('save').insert(data).select().single();
    return response['id'] as int;
  }

  // Mettre à jour une save
  Future<void> updateSave(SaveModel save) async {
    final data = save.toMap();
    await supabase.from('save').update(data).eq('id', save.id);
  }

  // Supprimer une save
  Future<void> deleteSave(int saveId) async {
    await supabase.from('save').delete().eq('id', saveId);
  }

  // Compter le nombre de saves par jeu
  Future<int> countSavesByGame(String gameId) async {
    final userId = supabase.auth.currentUser?.id;
    final response = await supabase
        .from('save')
        .select('id', const FetchOptions(count: CountOption.exact))
        .eq('game_id', gameId)
        .eq('user_id', userId);
    return response.count ?? 0;
  }
}

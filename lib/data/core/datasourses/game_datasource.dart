import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_model.dart';

class GameDatasource {
  final SupabaseClient supabase;

  GameDatasource(this.supabase);

  // Récupérer tous les jeux
  Future<List<GameModel>> getGames() async {
    final response = await supabase.from('game').select().order('priority');
    return (response as List).map((e) => GameModel.fromMap(e)).toList();
  }

  // Récupérer un jeu par ID
  Future<GameModel?> getGameById(String id) async {
    final response = await supabase.from('game').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return GameModel.fromMap(response);
  }

  // Ajouter un jeu
  Future<void> createGame(GameModel game) async {
    await supabase.from('game').insert(game.toMap());
  }

  // Mettre à jour un jeu
  Future<void> updateGame(GameModel game) async {
    await supabase.from('game').update(game.toMap()).eq('id', game.id);
  }

  // Supprimer un jeu
  Future<void> deleteGame(String id) async {
    await supabase.from('game').delete().eq('id', id);
  }
}

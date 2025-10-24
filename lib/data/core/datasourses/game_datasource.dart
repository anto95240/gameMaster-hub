import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gamemaster_hub/data/data_export.dart';

class GameDatasource {
  final SupabaseClient supabase;

  GameDatasource(this.supabase);

  Future<List<GameModel>> getGames() async {
    final response = await supabase
        .from('game')
        .select()
        .order('name', ascending: true);

    return (response as List).map((e) => GameModel.fromMap(e)).toList();
  }

  Future<GameModel?> getGameById(int id) async {
    final response = await supabase
        .from('game')
        .select()
        .eq('gameId', id)
        .maybeSingle();

    if (response == null) return null;
    return GameModel.fromMap(response);
  }

  Future<void> createGame(GameModel game) async {
    await supabase.from('game').insert(game.toMap());
  }

  Future<void> updateGame(GameModel game) async {
    await supabase.from('game').update(game.toMap()).eq('gameId', game.gameId);
  }

  Future<void> deleteGame(int id) async {
    await supabase.from('game').delete().eq('gameId', id);
  }
}

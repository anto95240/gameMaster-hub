import 'package:gamemaster_hub/domain/core/entities/game.dart';
import 'package:gamemaster_hub/domain/core/repositories/game_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GameRepositoryImpl implements GameRepository {
  @override
  final SupabaseClient supabase;

  GameRepositoryImpl(this.supabase);

  /// Récupère tous les jeux
  @override
  Future<List<Game>> getAllGames() async {
    final response = await supabase
        .from('game')
        .select()
        .order('name', ascending: true);

    if (response == null) return [];

    print('🧩 Données brutes depuis Supabase : $response');

    return (response as List).map((e) {
      final idValue = e['game_id']; // ✅ CORRECT
      final gameId = idValue is int ? idValue : int.tryParse(idValue.toString()) ?? 0;

      return Game(
        gameId: gameId,
        name: e['name'] ?? 'Jeu inconnu',
        description: e['description'],
        icon: e['icon'],
        route: e['route'],
      );
    }).toList();
  }

  /// Récupère un jeu par son ID
  @override
  Future<Game?> getGameById(int id) async {
    final response = await supabase
        .from('game')
        .select()
        .eq('game_id', id) // ✅ CORRECT
        .maybeSingle();

    if (response == null) return null;

    final gameId = response['game_id'] is int
        ? response['game_id']
        : int.tryParse(response['game_id'].toString()) ?? 0;

    return Game(
      gameId: gameId,
      name: response['name'] ?? 'Jeu inconnu',
      description: response['description'],
      icon: response['icon'],
      route: response['route'],
    );
  }
}

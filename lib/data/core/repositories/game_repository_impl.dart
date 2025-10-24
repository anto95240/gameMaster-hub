import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gamemaster_hub/domain/core/entities/game.dart';
import 'package:gamemaster_hub/domain/core/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  final SupabaseClient supabase;

  GameRepositoryImpl(this.supabase);

  /// 🔹 Helper pour extraire le count des saves
  int extractSavesCount(Map<String, dynamic> e) {
    final saves = e['save'];
    if (saves is List && saves.isNotEmpty) {
      final first = saves.first;
      final count = first['count'];
      if (count is int) return count;
      return int.tryParse(count.toString()) ?? 0;
    }
    return 0;
  }

  /// 🔹 Récupère tous les jeux
  @override
  Future<List<Game>> getAllGames() async {
    final response = await supabase
        .from('game')
        .select()
        .order('name', ascending: true);

    if (response == null) return [];

    return (response as List).map((e) {
      final gameId = e['game_id'] is int
          ? e['game_id']
          : int.tryParse(e['game_id'].toString()) ?? 0;

      return Game(
        gameId: gameId,
        name: e['name'] ?? 'Jeu inconnu',
        description: e['description'],
        icon: e['icon'],
        route: e['route'],
        savesCount: 0,
      );
    }).toList();
  }

  /// 🔹 Récupère un jeu par ID
  @override
  Future<Game?> getGameById(int id) async {
    final response = await supabase
        .from('game')
        .select()
        .eq('game_id', id)
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
      savesCount: 0,
    );
  }

  /// 🔹 Récupère tous les jeux avec le nombre de saves
  @override
  Future<List<Game>> getAllGamesWithSaves() async {
    final response = await supabase
        .from('game')
        .select('*, save(count)')
        .order('name', ascending: true);

    if (response == null) return [];

    return (response as List).map((e) {
      final gameId = e['game_id'] is int
          ? e['game_id']
          : int.tryParse(e['game_id'].toString()) ?? 0;

      return Game(
        gameId: gameId,
        name: e['name'] ?? 'Jeu inconnu',
        description: e['description'],
        icon: e['icon'],
        route: e['route'],
        savesCount: extractSavesCount(e),
      );
    }).toList();
  }

  /// 🔹 Récupère un jeu par ID avec le nombre de saves
  @override
  Future<Game?> getGameByIdWithSaves(int id) async {
    final response = await supabase
        .from('game')
        .select('*, save(count)')
        .eq('game_id', id)
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
      savesCount: extractSavesCount(response),
    );
  }
}

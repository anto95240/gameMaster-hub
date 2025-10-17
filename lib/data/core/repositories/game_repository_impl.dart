import '../../../domain/core/entities/game.dart';
import '../../../domain/core/repositories/game_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GameRepositoryImpl implements GameRepository {
  @override
  final SupabaseClient supabase;

  GameRepositoryImpl(this.supabase);

  @override
  Future<List<Game>> getAllGames() async {
    final response = await supabase
        .from('game')
        .select()
        .order('name', ascending: true);

    if (response == null) return [];

    return (response as List).map((e) => Game(
      gameId: int.tryParse(e['id'].toString()) ?? 0,
      name: e['name'],
      description: e['description'],
      icon: e['icon'],
      route: e['route'],
    )).toList();
  }

  @override
  Future<Game?> getGameById(int id) async {
    final response = await supabase
        .from('game')
        .select()
        .eq('id', id)
        .single();

    if (response == null) return null;

    return Game(
      gameId: int.tryParse(response['id'].toString()) ?? 0,
      name: response['name'],
      description: response['description'],
      icon: response['icon'],
      route: response['route'],
    );
  }
}

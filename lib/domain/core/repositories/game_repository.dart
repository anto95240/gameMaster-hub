import 'package:gamemaster_hub/domain/core/entities/game.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class GameRepository {
  SupabaseClient get supabase;

  Future<List<Game>> getAllGames();
  Future<Game?> getGameById(int id);
}

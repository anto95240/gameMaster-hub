// data/models/game_model.dart
import 'package:gamemaster_hub/domain/core/entities/game.dart';

class GameModel extends Game {
  GameModel({
    required super.gameId,
    required super.name,
    super.description,
    super.icon,
    super.route,
    super.savesCount,
  });

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      gameId: map['game_id'] is int
          ? map['game_id']
          : int.tryParse(map['game_id'].toString()) ?? 0,
      name: map['name'] ?? 'Jeu inconnu',
      description: map['description'],
      icon: map['icon'],
      route: map['route'],
      savesCount: map['saves_count'] is int
          ? map['saves_count']
          : int.tryParse(map['saves_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'game_id': gameId,
      'name': name,
      'description': description,
      'icon': icon,
      'route': route,
      'saves_count': savesCount,
    };
  }
}

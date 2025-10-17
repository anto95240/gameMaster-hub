import 'package:gamemaster_hub/domain/core/entities/game.dart';

class GameModel extends Game {
  GameModel({
    required super.gameId,
    required super.name,
    super.description,
    super.icon,
    super.route,
  });

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      gameId: map['game_id'] is int
          ? map['game_id']
          : int.tryParse(map['game_id'].toString()) ?? 0, // sécurité
      name: map['name'] ?? '',
      description: map['description'],
      icon: map['icon'],
      route: map['route'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'game_id': gameId,
      'name': name,
      'description': description,
      'icon': icon,
      'route': route,
    };
  }
}

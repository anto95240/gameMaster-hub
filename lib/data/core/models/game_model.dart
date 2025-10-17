import '../../../domain/core/entities/game.dart';

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
      gameId: map['gameId'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'],
      route: map['route'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'name': name,
      'description': description,
      'icon': icon,
      'route': route,
    };
  }
}

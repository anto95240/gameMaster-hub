import '../../../domain/core/entities/game.dart';

class GameModel extends Game {
  GameModel({
    required super.id,
    required super.name,
    super.description,
    super.icon,
    super.route,
  });

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'],
      route: map['route'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'route': route,
    };
  }
}

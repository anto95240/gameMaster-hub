import '../../../domain/core/entities/save.dart';

class SaveModel extends Save {
  SaveModel({
    required super.id,
    required super.gameId,
    required super.userId,
    required super.name,
    super.description,
    super.isActive,
    super.numberOfPlayers,
    super.overallRating,
  });

  factory SaveModel.fromMap(Map<String, dynamic> map) {
    return SaveModel(
      id: map['id'],
      gameId: map['game_id'],
      userId: map['user_id'],
      name: map['name'],
      description: map['description'],
      isActive: map['is_active'] ?? false,
      numberOfPlayers: map['number_of_players'] ?? 0,
      overallRating: (map['overall_rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'game_id': gameId,
      'user_id': userId,
      'name': name,
      'description': description,
      'is_active': isActive,
      'number_of_players': numberOfPlayers,
      'overall_rating': overallRating,
    };
  }
}

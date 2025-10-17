// lib/domain/core/entities/save.dart
class Save {
  final int id;
  final int gameId;
  final String userId;
  final String name;
  final String? description;
  final bool isActive;
  final int numberOfPlayers;
  final double overallRating;

  Save({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.name,
    this.description,
    this.isActive = false,
    this.numberOfPlayers = 0,
    this.overallRating = 0,
  });

  Save copyWith({
    int? id,
    int? gameId,
    String? userId,
    String? name,
    String? description,
    bool? isActive,
    int? numberOfPlayers,
    double? overallRating,
  }) {
    return Save(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      numberOfPlayers: numberOfPlayers ?? this.numberOfPlayers,
      overallRating: overallRating ?? this.overallRating,
    );
  }
}

class Save {
  final int id;
  final String gameId;
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
}

class Game {
  final int gameId;
  final String name;
  final String? description;
  final String? icon;
  final String? route;

  Game({
    required this.gameId,
    required this.name,
    this.description,
    this.icon,
    this.route,
  });
}

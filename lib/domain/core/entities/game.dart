class Game {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? route;

  Game({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.route,
  });
}

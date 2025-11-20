import 'package:go_router/go_router.dart';
import 'package:gamemaster_hub/domain/core/entities/game.dart';
import 'package:gamemaster_hub/domain/core/entities/save.dart';
import 'package:gamemaster_hub/presentation/sm/screens/sm_main_screen.dart';

class SmRouter {
  static List<GoRoute> routes = [
    GoRoute(
      path: '/sm/:saveId',
      name: 'soccer_manager',
      builder: (context, state) {
        final saveId = int.tryParse(state.pathParameters['saveId'] ?? '') ?? 0;
        final extraData = state.extra as Map<String, dynamic>?;
        final game = extraData?['game'] as Game?;
        final save = extraData?['save'] as Save?;
        return SMMainScreen(saveId: saveId, game: game, save: save);
      },
    ),
  ];
}
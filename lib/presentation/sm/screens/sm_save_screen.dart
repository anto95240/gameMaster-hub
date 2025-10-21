import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';
import 'package:gamemaster_hub/domain/core/entities/game.dart';
import 'package:gamemaster_hub/presentation/core/blocs/auth/auth_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/save/saves_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/save/saves_event.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/save/saves_state.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/save/save_card.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/save/save_dialog.dart';
import 'package:gamemaster_hub/presentation/core/widgets/custom_app_bar.dart';

class SmSaveScreen extends StatelessWidget {
  final int gameId;
  final Game game;
  final SavesBloc savesBloc;

  const SmSaveScreen({
    super.key,
    required this.gameId,
    required this.game,
    required this.savesBloc,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final String? currentUserId = authState is AuthAuthenticated ? authState.user.id : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = ResponsiveLayout.getScreenTypeFromWidth(constraints.maxWidth);
        final isMobileOrTablet = screenType == ScreenType.mobile || screenType == ScreenType.tablet;
        double screenWidth = constraints.maxWidth;
        double fontSize = screenWidth < 400
            ? 14
            : constraints.maxWidth < 600
                ? 16
                : 18;

        return BlocProvider.value(
          value: savesBloc..add(LoadSavesEvent(gameId: gameId)),
          child: Scaffold(
            appBar: CustomAppBar(
              title: 'Saves - ${game.name}',
              onBackPressed: () => context.go('/'),
              isMobile: isMobileOrTablet,
              mobileTitleSize: fontSize,
            ),
            body: BlocBuilder<SavesBloc, SavesState>(
              builder: (context, state) {
                if (state is SavesLoading) return const Center(child: CircularProgressIndicator());
                if (state is SavesError) return Center(child: Text('Erreur: ${state.message}'));
                if (state is SavesLoaded) {
                  return state.saves.isEmpty
                      ? const Center(child: Text('Aucune sauvegarde trouvée.'))
                      : _buildGrid(context, state.saves);
                }
                return const SizedBox.shrink();
              },
            ),
            floatingActionButton: currentUserId == null
                ? null
                : FloatingActionButton(
                    child: const Icon(Icons.add),
                    onPressed: () => _openSaveDialog(context, gameId, currentUserId),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, List<dynamic> saves) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int count = constraints.maxWidth >= 1200
            ? 4
            : constraints.maxWidth >= 800
                ? 3
                : constraints.maxWidth >= 500
                    ? 2
                    : 1;

        return Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.1,
            ),
            itemCount: saves.length,
            itemBuilder: (_, i) => SaveCard(save: saves[i], gameId: gameId),
          ),
        );
      },
    );
  }

  Future<void> _openSaveDialog(BuildContext context, int gameId, String userId) async {
    final result = await showDialog<Map<String, String>>(context: context, builder: (_) => const SaveDialog());
    if (result != null && context.mounted) {
      context.read<SavesBloc>().add(AddSaveEvent(
            gameId: gameId,
            userId: userId,
            name: result['name'] ?? '',
            description: result['description'] ?? '',
          ));
    }
  }
}

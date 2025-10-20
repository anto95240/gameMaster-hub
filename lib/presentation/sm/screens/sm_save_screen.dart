import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_event.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/core/entities/game.dart';
import '../blocs/save/saves_bloc.dart';
import '../blocs/save/saves_event.dart';
import '../blocs/save/saves_state.dart';
import '../../core/blocs/auth/auth_bloc.dart';
import '../../core/blocs/theme/theme_bloc.dart';

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
    final String? currentUserId =
        authState is AuthAuthenticated ? authState.user.id : null;

    final isMobile = MediaQuery.of(context).size.width < 600;

    return BlocProvider.value(
      value: savesBloc..add(LoadSavesEvent(gameId: gameId)),
      child: Scaffold(
        appBar: _buildAppBar(context, isMobile),
        drawer: isMobile ? _buildDrawer(context) : null,
        body: BlocBuilder<SavesBloc, SavesState>(
          builder: (context, state) {
            if (state is SavesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SavesLoaded) {
              return state.saves.isEmpty
                  ? const Center(child: Text('Aucune sauvegarde trouvée.'))
                  : _buildGrid(context, state);
            } else if (state is SavesError) {
              return Center(child: Text('Erreur: ${state.message}'));
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
  }

  /// --- APP BAR RESPONSIVE ---
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isMobile) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/'),
      ),
      title: Text(
        'Saves - ${game.name}',
        style: TextStyle(fontSize: isMobile ? 16 : 20),
      ),
      actions: isMobile
          ? null // actions dans le drawer pour mobile
          : [
              IconButton(
                onPressed: () =>
                    context.read<ThemeBloc>().add(ToggleTheme()),
                icon: BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (_, state) => Icon(
                    state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                ),
              ),
            ],
    );
  }

  /// --- DRAWER POUR MOBILE ---
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: const Text('Menu', style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () => context.go('/'),
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Recharger les joueurs'),
            onTap: () {
              context.read<JoueursSmBloc>().add(LoadJoueursSmEvent(gameId));
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Changer thème'),
            onTap: () {
              context.read<ThemeBloc>().add(ToggleTheme());
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  /// --- GRILLE RESPONSIVE DES SAVES ---
  Widget _buildGrid(BuildContext context, SavesLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 1200) crossAxisCount = 4;
        else if (constraints.maxWidth >= 800) crossAxisCount = 3;
        else if (constraints.maxWidth >= 500) crossAxisCount = 2;

        return Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.1,
            ),
            itemCount: state.saves.length,
            itemBuilder: (_, i) => _buildSaveCard(context, state.saves[i]),
          ),
        );
      },
    );
  }

  /// --- CARTE DE SAVE ---
  Widget _buildSaveCard(BuildContext context, dynamic save) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/sm'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader(context, save),
              if (save.description?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    save.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCard('Joueurs', '${save.numberOfPlayers}', Colors.teal),
                  _infoCard('Note', save.overallRating.toStringAsFixed(0),
                      Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardHeader(BuildContext context, dynamic save) {
    return Row(
      children: [
        Expanded(
          child: Text(
            save.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () => _editSaveDialog(context, save),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            context.read<SavesBloc>().add(DeleteSaveEvent(
                  saveId: save.id,
                  gameId: gameId,
                ));
          },
        ),
      ],
    );
  }

  /// --- MINI WIDGET INFO ---
  Widget _infoCard(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  /// --- DIALOGUES ---
  Future<void> _openSaveDialog(
      BuildContext context, int gameId, String userId) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _SaveDialog(),
    );
    if (result != null && context.mounted) {
      context.read<SavesBloc>().add(AddSaveEvent(
            gameId: gameId,
            userId: userId,
            name: result['name'] ?? '',
            description: result['description'] ?? '',
          ));
    }
  }

  Future<void> _editSaveDialog(BuildContext context, dynamic save) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _SaveDialog(save: save),
    );
    if (result != null && context.mounted) {
      context.read<SavesBloc>().add(UpdateSaveEvent(
            saveId: save.id,
            gameId: gameId,
            name: result['name'] ?? '',
            description: result['description'] ?? '',
          ));
    }
  }
}

class _SaveDialog extends StatefulWidget {
  final dynamic save;
  const _SaveDialog({this.save});

  @override
  State<_SaveDialog> createState() => _SaveDialogState();
}

class _SaveDialogState extends State<_SaveDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.save != null) {
      _nameController.text = widget.save.name;
      _descController.text = widget.save.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.save != null ? 'Modifier la sauvegarde' : 'Nouvelle sauvegarde'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom')),
          TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description')),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'name': _nameController.text,
            'description': _descController.text,
          }),
          child: const Text('Valider'),
        ),
      ],
    );
  }
}

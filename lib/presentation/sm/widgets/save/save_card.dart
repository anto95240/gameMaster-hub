import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gamemaster_hub/presentation/sm/blocs/save/saves_bloc.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/save/saves_event.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/save/save_dialog.dart';

class SaveCard extends StatelessWidget {
  final dynamic save;
  final int gameId;

  const SaveCard({super.key, required this.save, required this.gameId});

  @override
  Widget build(BuildContext context) {
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
              _cardHeader(context),
              if (save.description?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(save.description!, maxLines: 3, overflow: TextOverflow.ellipsis),
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCard('Joueurs', '${save.numberOfPlayers}', Colors.teal),
                  _infoCard('Note', save.overallRating.toStringAsFixed(0), Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardHeader(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(save.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editSave(context)),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => context.read<SavesBloc>().add(DeleteSaveEvent(saveId: save.id, gameId: gameId)),
          ),
        ],
      );

  Widget _infoCard(String title, String value, Color color) => Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      );

  Future<void> _editSave(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(context: context, builder: (_) => SaveDialog(save: save));
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class SaveCard extends StatelessWidget {
  final Save save;
  final int gameId;
  final Game game;

  const SaveCard({super.key, required this.save, required this.gameId, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.go('/sm/${save.id}', extra: {'game': game, 'save': save}),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader(context),
              const SizedBox(height: 4),
              if (save.description?.isNotEmpty ?? false)
                Text(
                  save.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCard('Joueurs', '${save.numberOfPlayers}', Colors.green),
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
        child: Text(
          save.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
        onPressed: () => _editSave(context),
      ),
      IconButton(
        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
        onPressed: () => context.read<SavesBloc>().add(
              DeleteSaveEvent(saveId: save.id, gameId: gameId),
            ),
      ),
    ],
  );

  Widget _infoCard(String title, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );

  Future<void> _editSave(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => SaveDialog(save: save),
    );
    if (result != null && context.mounted) {
      context.read<SavesBloc>().add(
        UpdateSaveEvent(
          saveId: save.id,
          gameId: gameId,
          name: result['name'] ?? '',
          description: result['description'] ?? '',
        ),
      );
    }
  }
}

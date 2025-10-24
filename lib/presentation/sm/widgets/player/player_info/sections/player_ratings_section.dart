import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

class PlayerRatingsSection extends StatefulWidget {
  final JoueurSm joueur;
  final bool isEditing;
  final Function(Map<String, int>) onRatingsChanged;

  const PlayerRatingsSection({
    super.key,
    required this.joueur,
    required this.isEditing,
    required this.onRatingsChanged,
  });

  @override
  State<PlayerRatingsSection> createState() => _PlayerRatingsSectionState();
}

class _PlayerRatingsSectionState extends State<PlayerRatingsSection> {
  late TextEditingController _niveauController;
  late TextEditingController _potentielController;

  @override
  void initState() {
    super.initState();
    _niveauController = TextEditingController(text: widget.joueur.niveauActuel.toString());
    _potentielController = TextEditingController(text: widget.joueur.potentiel.toString());
  }

  @override
  void dispose() {
    _niveauController.dispose();
    _potentielController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final niveau = widget.joueur.niveauActuel;
    final potentiel = widget.joueur.potentiel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        if (!widget.isEditing)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildSquareStatBox(
                context,
                value: niveau,
                color: getRatingColor(niveau),
              ),
              const SizedBox(width: 16),
              _buildSquareStatBox(
                context,
                value: potentiel,
                color: getProgressionColor(potentiel),
              ),
            ],
          )

        else
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Niveau',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  keyboardType: TextInputType.number,
                  controller: _niveauController,
                  onChanged: (value) {
                    final newMap = <String, int>{
                      'niveau_actuel': int.tryParse(value) ?? niveau,
                      'potentiel': int.tryParse(_potentielController.text) ?? potentiel,
                    };
                    widget.onRatingsChanged(newMap);
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 90,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Potentiel',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  keyboardType: TextInputType.number,
                  controller: _potentielController,
                  onChanged: (value) {
                    final newMap = <String, int>{
                      'niveau_actuel': int.tryParse(_niveauController.text) ?? niveau,
                      'potentiel': int.tryParse(value) ?? potentiel,
                    };
                    widget.onRatingsChanged(newMap);
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSquareStatBox(
    BuildContext context, {
    required int value,
    required Color color,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/sm/entities/joueur_sm.dart';

class PlayerRatingsSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final niveau = joueur.niveauActuel;
    final potentiel = joueur.potentiel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // 🔹 Affichage normal (non édition)
        if (!isEditing)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildSquareStatBox(
                context,
                value: niveau,
                color: _getRatingColor(niveau),
              ),
              const SizedBox(width: 16),
              _buildSquareStatBox(
                context,
                value: potentiel,
                color: _getPotentialColor(potentiel),
              ),
            ],
          )

        // 🔹 Mode édition
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
                  controller: TextEditingController(text: niveau.toString()),
                  onChanged: (value) {
                    final newMap = <String, int>{
                      'niveau_actuel': int.tryParse(value) ?? niveau,
                      'potentiel': potentiel,
                    };
                    onRatingsChanged(newMap);
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
                  controller: TextEditingController(text: potentiel.toString()),
                  onChanged: (value) {
                    final newMap = <String, int>{
                      'niveau_actuel': niveau,
                      'potentiel': int.tryParse(value) ?? potentiel,
                    };
                    onRatingsChanged(newMap);
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// 🔸 Widget carré pour note / potentiel
  Widget _buildSquareStatBox(
    BuildContext context, {
    required int value,
    required Color color,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
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

  /// 🔸 Couleur de la note actuelle
  Color _getRatingColor(int rating) {
    if (rating >= 85) return Colors.green;
    if (rating >= 80) return Colors.blue;
    return Colors.orange;
  }

  /// 🔸 Couleur du potentiel (légèrement différente pour contraste)
  Color _getPotentialColor(int potential) {
    if (potential >= 90) return Colors.lightGreen;
    if (potential >= 80) return Colors.cyan;
    return Colors.amber;
  }
}

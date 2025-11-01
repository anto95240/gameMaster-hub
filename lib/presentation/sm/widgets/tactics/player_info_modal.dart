import 'package:flutter/material.dart';

class PlayerInfoModal extends StatelessWidget {
  const PlayerInfoModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playerData = {
      'Nom': 'Chevalier',
      'Poste': 'GK',
      'Âge': '18 ans',
      'Contrat': '2029',
      'Note': '86',
      'Potentiel': '95',
      'Rôle individuel': 'Gardien libéro',
      'Description du rôle':
          'Gardien libéro moderne capable de sortir loin de sa ligne pour intercepter les ballons et relancer proprement.',
    };

    return Dialog(
      backgroundColor: const Color(0xFF2b2e3c),
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 400;

          return Container(
            width: constraints.maxWidth,
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 480, minHeight: 250),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: isMobile ? 42 : 52,
                      height: isMobile ? 42 : 52,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4dd0e1),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        playerData['Nom']![0],
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 18 : 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playerData['Nom']!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${playerData['Poste']} • ${playerData['Âge']} • ${playerData['Contrat']}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        _buildRatingBadge(playerData['Note']!),
                        const SizedBox(width: 6),
                        _buildRatingBadge(playerData['Potentiel']!,
                            isPotential: true),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(color: Color(0xFF3d4254)),
                const SizedBox(height: 16),

                // RÔLE + DESCRIPTION SUR 2 LIGNES
                Row(
                  children: [
                    const Icon(Icons.sports_soccer,
                        color: Colors.white38, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        playerData['Rôle individuel']!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isMobile ? 14 : 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  playerData['Description du rôle']!,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: isMobile ? 13 : 14,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _buildRatingBadge(String value, {bool isPotential = false}) {
    final int rating = int.tryParse(value) ?? 0;
    final Color color = rating >= 85
        ? const Color(0xFF4caf50)
        : (rating >= 75 ? const Color(0xFFffeb3b) : const Color(0xFFff9800));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

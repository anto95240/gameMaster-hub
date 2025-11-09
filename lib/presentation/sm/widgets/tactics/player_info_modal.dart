import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/core/utils/responsive_layout.dart';

class PlayerInfoModal extends StatelessWidget {
  final String? roleName;
  final String? roleDescription;

  const PlayerInfoModal({Key? key, this.roleName, this.roleDescription}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenType(context);

    final playerData = {
      'Nom': 'Chevalier',
      'Poste': 'GK',
      'Âge': '18 ans',
      'Contrat': '2029',
      'Note': '86',
      'Potentiel': '95',
      'Rôle individuel': roleName ?? 'Rôle optimisé',
      'Description du rôle': roleDescription ??
          'Rôle attribué automatiquement en fonction de la formation et des statistiques.',
    };

    final maxWidth = switch (screenType) {
      ScreenType.mobile => 360.0,
      ScreenType.tablet => 440.0,
      ScreenType.laptop => 480.0,
      ScreenType.laptopL => 520.0,
    };

    final avatarSize = switch (screenType) {
      ScreenType.mobile => 42.0,
      ScreenType.tablet => 50.0,
      ScreenType.laptop => 56.0,
      ScreenType.laptopL => 60.0,
    };

    final titleSize = switch (screenType) {
      ScreenType.mobile => 16.0,
      ScreenType.tablet => 17.0,
      ScreenType.laptop => 18.0,
      ScreenType.laptopL => 20.0,
    };

    final textSize = switch (screenType) {
      ScreenType.mobile => 13.0,
      ScreenType.tablet => 14.0,
      ScreenType.laptop => 15.0,
      ScreenType.laptopL => 16.0,
    };

    return Dialog(
      backgroundColor: const Color(0xFF2b2e3c),
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: maxWidth,
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(minHeight: 250),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
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
                      fontSize: avatarSize * 0.45,
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
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${playerData['Poste']} • ${playerData['Âge']} • ${playerData['Contrat']}",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: textSize - 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    _buildRatingBadge(playerData['Note']!, screenType),
                    _buildRatingBadge(playerData['Potentiel']!,
                        screenType, isPotential: true),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),
            const Divider(color: Color(0xFF3d4254)),
            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.sports_soccer,
                    color: Colors.white38, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    playerData['Rôle individuel']!,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: textSize,
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
                fontSize: textSize - 1,
                height: 1.4,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildRatingBadge(
    String value,
    ScreenType screenType, {
    bool isPotential = false,
  }) {
    final int rating = int.tryParse(value) ?? 0;
    final Color color = rating >= 85
        ? const Color(0xFF4caf50)
        : (rating >= 75
            ? const Color(0xFFffeb3b)
            : const Color(0xFFff9800));

    final double fontSize = switch (screenType) {
      ScreenType.mobile => 12,
      ScreenType.tablet => 13,
      ScreenType.laptop => 14,
      ScreenType.laptopL => 15,
    };

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
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

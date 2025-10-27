// soccer_field_mobile_overlay.dart
import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/sm_tactic_tab/player_with_position.dart';

class MobilePlayerBottomSheet extends StatelessWidget {
  final PlayerWithPosition playerPos;
  final VoidCallback? onViewDetails;

  const MobilePlayerBottomSheet({
    super.key,
    required this.playerPos,
    this.onViewDetails,
  });

  static void show(
    BuildContext context,
    PlayerWithPosition playerPos, {
    VoidCallback? onViewDetails,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobilePlayerBottomSheet(
        playerPos: playerPos,
        onViewDetails: onViewDetails,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = getPositionColor(playerPos.position);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C3A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        playerPos.position,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${playerPos.player.overall}',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playerPos.player.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Compatibilité: ${playerPos.compatibility.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _getCompatibilityColor(playerPos.compatibility),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoGrid(context),
            const SizedBox(height: 24),
            if (_hasStats(playerPos.player)) ...[
              Text('Statistiques', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildStatsGrid(context),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onViewDetails?.call();
                },
                icon: const Icon(Icons.person),
                label: const Text('Voir la fiche complète'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildInfoCard(context, 'Âge', '${playerPos.player.age ?? "N/A"}', Icons.cake)),
        const SizedBox(width: 12),
        Expanded(child: _buildInfoCard(context, 'Poste préféré', playerPos.player.preferredPosition ?? 'N/A', Icons.star)),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final stats = [
      if (playerPos.player.pace != null) ('Vitesse', playerPos.player.pace!, Icons.directions_run),
      if (playerPos.player.shooting != null) ('Tir', playerPos.player.shooting!, Icons.sports_soccer),
      if (playerPos.player.passing != null) ('Passe', playerPos.player.passing!, Icons.swap_horiz),
      if (playerPos.player.dribbling != null) ('Dribble', playerPos.player.dribbling!, Icons.sports_handball),
      if (playerPos.player.defending != null) ('Défense', playerPos.player.defending!, Icons.shield),
      if (playerPos.player.physical != null) ('Physique', playerPos.player.physical!, Icons.fitness_center),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(context, stat.$1, stat.$2, stat.$3);
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String label, int value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getStatColor(value);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600]), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(value.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  bool _hasStats(TacticPlayer player) {
    return player.pace != null ||
        player.shooting != null ||
        player.passing != null ||
        player.dribbling != null ||
        player.defending != null ||
        player.physical != null;
  }

  Color _getStatColor(int value) {
    if (value >= 80) return Colors.green;
    if (value >= 70) return Colors.lightGreen;
    if (value >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getCompatibilityColor(double compatibility) {
    if (compatibility >= 90) return Colors.green;
    if (compatibility >= 75) return Colors.lightGreen;
    if (compatibility >= 60) return Colors.orange;
    return Colors.red;
  }
}

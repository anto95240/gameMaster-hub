import 'package:flutter/material.dart';

class AnalyseCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  final Color borderColor;
  final IconData icon;

  const AnalyseCard({
    super.key,
    required this.title,
    required this.items,
    required this.color,
    required this.borderColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withOpacity(0.7), width: 1.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: borderColor),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: borderColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Center(
              child: Text("Aucune donnée disponible",
                  style: TextStyle(color: Colors.white54)),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.white70),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14, height: 1.3)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

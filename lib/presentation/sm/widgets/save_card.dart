import 'package:flutter/material.dart';

class SaveCard extends StatelessWidget {
  final String title;
  final String? description;
  final bool isActive;
  final double cardWidth;
  final VoidCallback onTap;

  const SaveCard({
    super.key,
    required this.title,
    this.description,
    this.isActive = false,
    required this.cardWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isActive ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isActive ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (isActive)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Chip(
                    label: const Text('Active'),
                    backgroundColor: Colors.green.shade100,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

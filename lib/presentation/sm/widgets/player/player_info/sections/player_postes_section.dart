import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/common/enums.dart';
import 'package:gamemaster_hub/domain/sm/entities/joueur_sm.dart';

class PlayerPostesSection extends StatefulWidget {
  final JoueurSm joueur;
  final bool isEditing;
  final Function(List<PosteEnum>)? onPostesChanged;
  
  const PlayerPostesSection({
    super.key,
    required this.joueur,
    required this.isEditing,
    this.onPostesChanged,
  });

  @override
  State<PlayerPostesSection> createState() => _PlayerPostesSectionState();
}

class _PlayerPostesSectionState extends State<PlayerPostesSection> {
  late List<PosteEnum> _selectedPostes;

  @override
  void initState() {
    super.initState();
    _selectedPostes = List.from(widget.joueur.postes);
  }

  void _togglePoste(PosteEnum poste) {
    setState(() {
      if (_selectedPostes.contains(poste)) {
        _selectedPostes.remove(poste);
      } else {
        _selectedPostes.add(poste);
      }
    });
    widget.onPostesChanged?.call(_selectedPostes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Postes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        if (widget.isEditing)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PosteEnum.values.map((poste) {
              final isSelected = _selectedPostes.contains(poste);
              return FilterChip(
                label: Text(poste.name),
                selected: isSelected,
                onSelected: (_) => _togglePoste(poste),
                selectedColor: Colors.blue.withOpacity(0.2),
                checkmarkColor: Colors.blue,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              );
            }).toList(),
          )
        
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.joueur.postes.map((poste) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  poste.name,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

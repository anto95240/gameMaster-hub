import 'package:flutter/material.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';

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
        const Text(
          'Postes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        if (widget.isEditing)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PosteEnum.values.map((poste) {
              final isSelected = _selectedPostes.contains(poste);
              final color = getPositionColor(poste.name);

              return FilterChip(
                label: Text(
                  poste.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: isSelected,
                backgroundColor: color.withOpacity(0.1),
                selectedColor: color,
                checkmarkColor: Colors.white,
                onSelected: (_) => _togglePoste(poste),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: color,
                    width: 1.5,
                  ),
                ),
              );
            }).toList(),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.joueur.postes.map((poste) {
              final color = getPositionColor(poste.name);

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Text(
                  poste.name,
                  style: TextStyle(
                    color: color,
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
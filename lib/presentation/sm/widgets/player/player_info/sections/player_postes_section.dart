import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:gamemaster_hub/domain/common/enums.dart';
import 'package:gamemaster_hub/domain/sm/entities/joueur_sm.dart';

class PlayerPostesSection extends StatefulWidget {
  final JoueurSm joueur;
  final bool isEditing;
  const PlayerPostesSection({
    super.key,
    required this.joueur,
    required this.isEditing,
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

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      return SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: MultiSelectDialogField<PosteEnum>(
            items: PosteEnum.values
                .map((p) => MultiSelectItem<PosteEnum>(p, p.name))
                .toList(),
            initialValue: _selectedPostes,
            title: const Text('Postes'),
            buttonText: Text(
              _selectedPostes.map((e) => e.name).join(' / '),
              overflow: TextOverflow.ellipsis,
            ),
            onConfirm: (values) => setState(() => _selectedPostes = values),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.joueur.postes.map((e) => e.name).join('/'),
        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamemaster_hub/domain/domain_export.dart';
import 'package:gamemaster_hub/presentation/presentation_export.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/player/player_utils.dart';

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
  late StatusEnum _selectedStatus;

  @override
  void initState() {
    super.initState();
    _niveauController = TextEditingController(text: widget.joueur.niveauActuel.toString());
    _potentielController = TextEditingController(text: widget.joueur.potentiel.toString());
    _selectedStatus = widget.joueur.status;
  }
  
  @override
  void didUpdateWidget(covariant PlayerRatingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.joueur != oldWidget.joueur) {
      _niveauController.text = widget.joueur.niveauActuel.toString();
      _potentielController.text = widget.joueur.potentiel.toString();
      _selectedStatus = widget.joueur.status;
    }
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 350;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            if (!widget.isEditing)
              Row(
                children: [
                  _buildSquareStatBox(
                    value: niveau.toString(),
                    color: getRatingColor(niveau),
                    fixedSize: 40,
                  ),
                  const SizedBox(width: 12),
                  _buildSquareStatBox(
                    value: potentiel.toString(),
                    color: getProgressionColor(potentiel),
                    fixedSize: 40,
                  ),
                  const SizedBox(width: 12),

                  IntrinsicWidth(
                    child: _buildSquareStatBox(
                      value: _selectedStatus.name,
                      color: Colors.grey.shade600,
                      fixedSize: null,
                    ),
                  ),
                ],
              )

            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: isSmall ? 70 : 90,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Niveau',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: _niveauController,
                      onChanged: (value) {
                        widget.onRatingsChanged({
                          'niveau_actuel': int.tryParse(value) ?? niveau,
                          'potentiel': int.tryParse(_potentielController.text) ?? potentiel,
                          'status': _selectedStatus.index,
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  SizedBox(
                    width: isSmall ? 70 : 90,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Potentiel',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: _potentielController,
                      onChanged: (value) {
                        widget.onRatingsChanged({
                          'niveau_actuel': int.tryParse(_niveauController.text) ?? niveau,
                          'potentiel': int.tryParse(value) ?? potentiel,
                          'status': _selectedStatus.index,
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: DropdownButtonFormField<StatusEnum>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                      ),
                      isExpanded: true,
                      items: StatusEnum.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.name, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (newStatus) {
                        if (newStatus == null) return;
                        setState(() => _selectedStatus = newStatus);

                        widget.onRatingsChanged({
                          'niveau_actuel': int.tryParse(_niveauController.text) ?? niveau,
                          'potentiel': int.tryParse(_potentielController.text) ?? potentiel,
                          'status': newStatus.index,
                        });
                      },
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildSquareStatBox({
    required String value,
    required Color color,
    double? fixedSize,
  }) {
    return Container(
      width: fixedSize,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: fixedSize == null ? 14 : 16,
            ),
          ),
        ),
      ),
    );
  }
}
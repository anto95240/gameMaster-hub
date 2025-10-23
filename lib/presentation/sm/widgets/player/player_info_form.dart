import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:gamemaster_hub/domain/common/enums.dart';
import 'package:gamemaster_hub/domain/sm/entities/joueur_sm.dart';
import 'package:gamemaster_hub/presentation/sm/blocs/joueurs/joueurs_sm_state.dart';

class PlayerInfoForm extends StatefulWidget {
  final JoueurSmWithStats item;
  final bool isEditing;
  final ValueChanged<bool> onEditingChanged;

  const PlayerInfoForm({
    super.key,
    required this.item,
    required this.isEditing,
    required this.onEditingChanged,
  });

  @override
  State<PlayerInfoForm> createState() => _PlayerInfoFormState();
}

class _PlayerInfoFormState extends State<PlayerInfoForm> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _ratingController;
  late TextEditingController _potentielController;
  late TextEditingController _valueController;
  late TextEditingController _dureeContratController;
  late TextEditingController _salaireController;
  late String _selectedStatus;
  late List<PosteEnum> _selectedPostes;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final joueur = widget.item.joueur;
    _nameController = TextEditingController(text: joueur.nom);
    _ageController = TextEditingController(text: joueur.age.toString());
    _ratingController = TextEditingController(text: joueur.niveauActuel.toString());
    _potentielController = TextEditingController(text: joueur.potentiel.toString());
    _valueController = TextEditingController(text: joueur.montantTransfert.toString());
    _dureeContratController = TextEditingController(text: joueur.dureeContrat.toString());
    _salaireController = TextEditingController(text: joueur.salaire.toString());
    _selectedStatus = joueur.status.name;
    _selectedPostes = List.from(joueur.postes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _ratingController.dispose();
    _potentielController.dispose();
    _valueController.dispose();
    _dureeContratController.dispose();
    _salaireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = isDark ? const Color(0xFF2C2C3A) : const Color(0xFFE5E7EB);

    return Column(
      children: [
        _buildHeader(context, headerColor),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlayerAvatar(),
                    const SizedBox(width: 24),
                    Expanded(child: _buildPlayerInfo(context)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Color headerColor) {
    final joueur = widget.item.joueur;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: widget.isEditing
                ? TextField(
                    controller: _nameController,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(
                    joueur.nom,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerAvatar() {
    final joueur = widget.item.joueur;
    final initial = joueur.nom.isNotEmpty ? joueur.nom[0].toUpperCase() : '?';
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.blue[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(BuildContext context) {
    final joueur = widget.item.joueur;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusField(context, joueur),
        const SizedBox(height: 8),
        _buildContractField(context, joueur),
        const SizedBox(height: 12),
        _buildPostesAndAgeRow(context, joueur),
        const SizedBox(height: 12),
        _buildRatingsRow(context, joueur),
        const SizedBox(height: 12),
        _buildValueField(context, joueur),
        const SizedBox(height: 12),
        _buildSalaryField(context, joueur),
      ],
    );
  }

  Widget _buildStatusField(BuildContext context, JoueurSm joueur) {
    if (widget.isEditing) {
      return DropdownButtonFormField<String>(
        value: _selectedStatus,
        decoration: const InputDecoration(
          labelText: 'Statut',
          border: OutlineInputBorder(),
        ),
        items: StatusEnum.values
            .map((s) => DropdownMenuItem(value: s.name, child: Text(s.name)))
            .toList(),
        onChanged: (v) => setState(() => _selectedStatus = v!),
      );
    }
    
    return Text(
      joueur.status.name,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildContractField(BuildContext context, JoueurSm joueur) {
    if (widget.isEditing) {
      return TextField(
        controller: _dureeContratController,
        decoration: const InputDecoration(
          labelText: 'Durée contrat (années)',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      );
    }
    
    return Text(
      'Contrat jusqu\'à ${joueur.dureeContrat}',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildPostesAndAgeRow(BuildContext context, JoueurSm joueur) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildPostesField(context, joueur),
        _buildAgeField(context, joueur),
      ],
    );
  }

  Widget _buildPostesField(BuildContext context, JoueurSm joueur) {
    if (widget.isEditing) {
      return SizedBox(
        width: 120,
        child: MultiSelectDialogField<PosteEnum>(
          items: PosteEnum.values
              .map((p) => MultiSelectItem<PosteEnum>(p, p.name))
              .toList(),
          initialValue: _selectedPostes,
          title: const Text('Postes'),
          buttonText: Text(_selectedPostes.map((e) => e.name).join('/')),
          onConfirm: (values) => setState(() => _selectedPostes = values),
        ),
      );
    }
    
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.4)),
      ),
      child: Text(
        joueur.postes.map((e) => e.name).join('/'),
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAgeField(BuildContext context, JoueurSm joueur) {
    if (widget.isEditing) {
      return SizedBox(
        width: 80,
        child: TextField(
          controller: _ageController,
          decoration: const InputDecoration(
            labelText: 'Âge',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      );
    }
    
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.4)),
      ),
      child: Text(
        '${joueur.age} ans',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRatingsRow(BuildContext context, JoueurSm joueur) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildRatingField(context, joueur),
        _buildPotentialField(context, joueur),
      ],
    );
  }

  Widget _buildRatingField(BuildContext context, JoueurSm joueur) {
    if (widget.isEditing) {
      return SizedBox(
        width: 100,
        child: TextField(
          controller: _ratingController,
          decoration: const InputDecoration(
            labelText: 'Note',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      );
    }
    
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.4), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${joueur.niveauActuel}',
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const Text(
            'NOTE',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPotentialField(BuildContext context, JoueurSm joueur) {
    if (widget.isEditing) {
      return SizedBox(
        width: 100,
        child: TextField(
          controller: _potentielController,
          decoration: const InputDecoration(
            labelText: 'Potentiel',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      );
    }
    
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.4), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${joueur.potentiel}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const Text(
            'POT',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueField(BuildContext context, JoueurSm joueur) {
    if (widget.isEditing) {
      return TextField(
        controller: _valueController,
        decoration: const InputDecoration(
          labelText: 'Montant transfert',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      );
    }
    
    return Text(
      '${joueur.montantTransfert} M€',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildSalaryField(BuildContext context, JoueurSm joueur) {
    if (widget.isEditing) {
      return TextField(
        controller: _salaireController,
        decoration: const InputDecoration(
          labelText: 'Salaire',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      );
    }
    
    return Text(
      '${joueur.salaire} K€/semaine',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
    );
  }
}
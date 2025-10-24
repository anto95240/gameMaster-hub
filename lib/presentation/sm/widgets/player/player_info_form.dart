import 'package:flutter/material.dart';
import 'package:gamemaster_hub/presentation/sm/widgets/player/player_info/player_info_body.dart';
import 'package:gamemaster_hub/domain/common/enums.dart';
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
  State<PlayerInfoForm> createState() => PlayerInfoFormState();
}

class PlayerInfoFormState extends State<PlayerInfoForm> {
  late TextEditingController _nameController;
  
  TextEditingController get nameController => _nameController;
  late TextEditingController _ageController;
  late TextEditingController _ratingController;
  late TextEditingController _potentielController;
  late TextEditingController _valueController;
  late TextEditingController _dureeContratController;
  late TextEditingController _salaireController;
  late String _selectedStatus;
  
  Map<String, int> _ratingsData = {};
  int _valueData = 0;
  int _salaryData = 0;
  int _durationData = 0;
  List<PosteEnum> _postesData = [];

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
    
    _ratingsData = {
      'niveau_actuel': joueur.niveauActuel,
      'potentiel': joueur.potentiel,
    };
    _valueData = joueur.montantTransfert;
    _salaryData = joueur.salaire;
    _durationData = joueur.dureeContrat;
    _postesData = List.from(joueur.postes);
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

  Map<String, dynamic> getFormData() {
    return {
      'nom': _nameController.text,
      'age': int.tryParse(_ageController.text) ?? widget.item.joueur.age,
      'niveau_actuel': _ratingsData['niveau_actuel'] ?? widget.item.joueur.niveauActuel,
      'potentiel': _ratingsData['potentiel'] ?? widget.item.joueur.potentiel,
      'montant_transfert': _valueData,
      'duree_contrat': _durationData,
      'salaire': _salaryData,
      'status': _selectedStatus,
      'postes': _postesData.map((p) => p.name).toList(),
    };
  }
  
  void _onRatingsChanged(Map<String, int> ratings) {
    setState(() {
      _ratingsData = ratings;
    });
  }
  
  void _onValueSalaryChanged(int value, int salary) {
    setState(() {
      _valueData = value;
      _salaryData = salary;
    });
  }
  
  void _onPostesChanged(List<PosteEnum> postes) {
    setState(() {
      _postesData = postes;
    });
  }
  
  void _onDurationChanged(int duration) {
    setState(() {
      _durationData = duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlayerInfoBody(
      item: widget.item,
      isEditing: widget.isEditing,
      onEditingChanged: widget.onEditingChanged,
      onRatingsChanged: _onRatingsChanged,
      onValueSalaryChanged: _onValueSalaryChanged,
      onPostesChanged: _onPostesChanged,
      onDurationChanged: _onDurationChanged,
    );
  }
}
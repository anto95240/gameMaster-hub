import 'package:gamemaster_hub/domain/common/enums.dart';

class JoueurSm {
  final int id;
  final String nom;
  final int age;
  final List<PosteEnum> postes; // plusieurs postes possibles
  final int niveauActuel;
  final int potentiel;
  final int montantTransfert;
  final StatusEnum status;
  final int dureeContrat;
  final int salaire;
  final String userId;

  JoueurSm({
    required this.id,
    required this.nom,
    required this.age,
    required this.postes,
    required this.niveauActuel,
    required this.potentiel,
    required this.montantTransfert,
    required this.status,
    required this.dureeContrat,
    required this.salaire,
    required this.userId,
  });
}

import 'package:gamemaster_hub/domain/domain_export.dart';

class JoueurSm {
  final int id;
  final int saveId; 
  final String nom;
  final int age;
  final List<PosteEnum> postes;
  final int niveauActuel;
  final int potentiel;
  final int montantTransfert;
  final StatusEnum status;
  final int dureeContrat;
  final int salaire;
  final String userId;

  JoueurSm({
    required this.id,
    required this.saveId,
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

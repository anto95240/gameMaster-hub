import '../entities/joueur_sm.dart';

abstract class JoueurSmRepository {
  Future<List<JoueurSm>> getAllJoueurs(int saveId);
  Future<JoueurSm> getJoueurById(int id, int saveId);
  Future<void> insertJoueur(JoueurSm joueur);
  Future<void> updateJoueur(JoueurSm joueur);
  Future<void> deleteJoueur(int id);
}

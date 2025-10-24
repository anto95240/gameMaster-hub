import 'package:gamemaster_hub/domain/domain_export.dart';

abstract class TactiqueJoueurSmRepository {
  Future<List<TactiqueJoueurSm>> getAll(int saveId);
  Future<List<TactiqueJoueurSm>> getByTactiqueId(int tactiqueId, int saveId);
  Future<void> insert(TactiqueJoueurSm tj);
  Future<void> update(TactiqueJoueurSm tj);
  Future<void> delete(int id);
}

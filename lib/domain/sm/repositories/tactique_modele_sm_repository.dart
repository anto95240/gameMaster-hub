import 'package:gamemaster_hub/domain/domain_export.dart';

abstract class TactiqueModeleSmRepository {
  Future<List<TactiqueModeleSm>> getAllTactiques(int saveId);
  Future<TactiqueModeleSm?> getTactiqueById(int id, int saveId);
  Future<void> insertTactique(TactiqueModeleSm tactique);
  Future<void> updateTactique(TactiqueModeleSm tactique);
  Future<void> deleteTactique(int id);
}

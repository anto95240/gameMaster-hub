import 'package:gamemaster_hub/domain/domain_export.dart';

abstract class TactiqueModeleSmRepository {
  Future<List<TactiqueModeleSm>> getAllTactiques();
  Future<TactiqueModeleSm?> getTactiqueById(int id);
  Future<void> insertTactique(TactiqueModeleSm tactique);
  Future<void> updateTactique(TactiqueModeleSm tactique);
  Future<void> deleteTactique(int id);
}

import 'package:gamemaster_hub/domain/domain_export.dart';

abstract class TactiqueUserSmRepository {
  Future<List<TactiqueUserSm>> getAll(int saveId);
  Future<TactiqueUserSm?> getLatest(int saveId);
  Future<int> insert(TactiqueUserSm tactique);
  Future<void> update(TactiqueUserSm tactique);
  Future<void> delete(int id);
}

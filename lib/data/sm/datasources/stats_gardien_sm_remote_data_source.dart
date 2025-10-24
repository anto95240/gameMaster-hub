import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gamemaster_hub/data/data_export.dart';

class StatsGardienSmRemoteDataSource {
  final SupabaseClient client;
  StatsGardienSmRemoteDataSource(this.client);

  Future<List<StatsGardienSmModel>> fetchStats(int saveId) async {
    final response = await client
        .from('stats_gardien_sm')
        .select()        
        .eq('save_id', saveId)
        .execute();
    final data = response.data as List<dynamic>;
    return data.map((e) => StatsGardienSmModel.fromMap(e)).toList();
  }

  Future<StatsGardienSmModel?> fetchStatsGardien(int joueurId, int saveId) async {
    final res = await client
        .from('stats_gardien_sm')
        .select()
        .eq('joueur_id', joueurId)
        .eq('save_id', saveId)
        .maybeSingle();

    if (res == null) return null;
    return StatsGardienSmModel.fromMap(res);
  }

  Future<void> insertStatsGardien(StatsGardienSmModel stats) async {
    await client.from('stats_gardien_sm').insert(stats.toMap());
  }

  Future<void> updateStatsGardien(StatsGardienSmModel stats) async {
    await client.from('stats_gardien_sm').update(stats.toMap()).eq('id', stats.id);
  }

  Future<void> deleteStats(int id) async {
    await client.from('stats_gardien_sm').delete().eq('id', id);
  }
}

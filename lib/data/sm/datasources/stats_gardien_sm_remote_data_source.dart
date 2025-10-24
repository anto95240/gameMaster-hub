import 'package:supabase_flutter/supabase_flutter.dart';

class StatsGardienSmRemoteDataSource {
  final SupabaseClient client;
  StatsGardienSmRemoteDataSource(this.client);

  Future<List<Map<String, dynamic>>> fetchStats(int saveId) async {
    final response = await client
        .from('stats_gardien_sm')
        .select()        
        .eq('save_id', saveId)
        .execute();
    final data = response.data as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> fetchStatsGardien(int joueurId, int saveId) async {
    final res = await client
        .from('stats_gardien_sm')
        .select()
        .eq('joueur_id', joueurId)
        .eq('save_id', saveId)
        .maybeSingle();

    return res;
  }

  Future<void> insertStatsGardien(Map<String, dynamic> data) async {
    await client.from('stats_gardien_sm').insert(data);
  }

  Future<void> updateStatsGardien(int id, Map<String, dynamic> data) async {
    await client.from('stats_gardien_sm').update(data).eq('id', id);
  }

  Future<void> deleteStats(int id) async {
    await client.from('stats_gardien_sm').delete().eq('id', id);
  }
}

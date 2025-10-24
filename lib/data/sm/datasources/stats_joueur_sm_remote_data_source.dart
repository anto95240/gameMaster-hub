import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gamemaster_hub/data/sm/models/stats_joueur_sm_model.dart';

class StatsJoueurSmRemoteDataSource {
  final SupabaseClient supabase;

  StatsJoueurSmRemoteDataSource(this.supabase);

  Future<List<StatsJoueurSmModel>> fetchStats(int saveId) async {
    final response = await supabase
        .from('stats_joueur_sm')
        .select()        
        .eq('save_id', saveId)
        .execute();
    final data = response.data as List<dynamic>;
    return data.map((e) => StatsJoueurSmModel.fromMap(e)).toList();
  }

  Future<void> insertStats(StatsJoueurSmModel stats) async {
    await supabase.from('stats_joueur_sm').insert(stats.toMap()).execute();
  }

  Future<void> updateStats(StatsJoueurSmModel stats) async {
    await supabase.from('stats_joueur_sm')
        .update(stats.toMap())
        .eq('id', stats.id)
        .execute();
  }

  Future<void> deleteStats(int id) async {
    await supabase.from('stats_joueur_sm').delete().eq('id', id).execute();
  }
}

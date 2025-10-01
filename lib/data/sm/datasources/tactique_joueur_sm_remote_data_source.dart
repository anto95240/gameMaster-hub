import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tactique_joueur_sm_model.dart';

class TactiqueJoueurSmRemoteDataSource {
  final SupabaseClient supabase;

  TactiqueJoueurSmRemoteDataSource(this.supabase);

  Future<List<TactiqueJoueurSmModel>> fetchAll() async {
    final response = await supabase.from('tactique_joueur_sm').select().execute();
    final data = response.data as List<dynamic>;
    return data.map((e) => TactiqueJoueurSmModel.fromMap(e)).toList();
  }

  Future<void> insert(TactiqueJoueurSmModel tj) async {
    await supabase.from('tactique_joueur_sm').insert(tj.toMap()).execute();
  }

  Future<void> update(TactiqueJoueurSmModel tj) async {
    await supabase.from('tactique_joueur_sm').update(tj.toMap()).eq('id', tj.id).execute();
  }

  Future<void> delete(int id) async {
    await supabase.from('tactique_joueur_sm').delete().eq('id', id).execute();
  }
}

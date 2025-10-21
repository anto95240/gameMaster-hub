import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gamemaster_hub/data/sm/models/joueur_sm_model.dart';

abstract class JoueurSmRemoteDataSource {
  Future<List<JoueurSmModel>> fetchJoueurs(int saveId);
  Future<void> insertJoueur(JoueurSmModel joueur);
  Future<void> updateJoueur(JoueurSmModel joueur);
  Future<void> deleteJoueur(int id);
}

class JoueurSmRemoteDataSourceImpl implements JoueurSmRemoteDataSource {
  final SupabaseClient supabase;

  JoueurSmRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<JoueurSmModel>> fetchJoueurs(int saveId) async {
    final response = await supabase
        .from('joueur_sm')
        .select()
        .eq('save_id', saveId)
        .execute();
    final data = response.data as List<dynamic>;
    return data.map((e) => JoueurSmModel.fromMap(e)).toList();
  }

  @override
  Future<void> insertJoueur(JoueurSmModel joueur) async {
    await supabase.from('joueur_sm').insert(joueur.toMap()).execute();
  }

  @override
  Future<void> updateJoueur(JoueurSmModel joueur) async {
    await supabase.from('joueur_sm').update(joueur.toMap()).eq('id', joueur.id).execute();
  }

  @override
  Future<void> deleteJoueur(int id) async {
    await supabase.from('joueur_sm').delete().eq('id', id).execute();
  }
}

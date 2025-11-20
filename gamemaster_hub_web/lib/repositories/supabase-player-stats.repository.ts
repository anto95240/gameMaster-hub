import { supabase } from '@/lib/supabaseClient';
import { PlayerStats } from '@/domain/entities/player-stats';
import { IPlayerStatsRepository } from '@/domain/interfaces/player-stats-repository.interface';

export class SupabasePlayerStatsRepository implements IPlayerStatsRepository {
  
  async getAllStats(saveId: number): Promise<PlayerStats[]> {
    const { data, error } = await supabase
      .from('stats_joueur_sm')
      .select('*')
      .eq('save_id', saveId);

    if (error) throw new Error(error.message);
    return data.map(this.mapToEntity);
  }

  async getStatsByPlayerId(playerId: number, saveId: number): Promise<PlayerStats | null> {
    const { data, error } = await supabase
      .from('stats_joueur_sm')
      .select('*')
      .match({ joueur_id: playerId, save_id: saveId })
      .maybeSingle();

    if (error) throw new Error(error.message);
    return data ? this.mapToEntity(data) : null;
  }

  async insertStats(stats: PlayerStats): Promise<void> {
    const { error } = await supabase.from('stats_joueur_sm').insert(this.mapToRow(stats));
    if (error) throw new Error(error.message);
  }

  async updateStats(stats: PlayerStats): Promise<void> {
    const { error } = await supabase
      .from('stats_joueur_sm')
      .update(this.mapToRow(stats))
      .eq('id', stats.id);
    if (error) throw new Error(error.message);
  }

  async deleteStats(id: number): Promise<void> {
    const { error } = await supabase.from('stats_joueur_sm').delete().eq('id', id);
    if (error) throw new Error(error.message);
  }

  private mapToEntity(row: any): PlayerStats {
    return {
      id: row.id,
      joueurId: row.joueur_id,
      saveId: row.save_id,
      marquage: row.marquage,
      tacles: row.tacles,
      finition: row.finition,
      passes: row.passes,
      passesLongues: row.passes_longues,
      centres: row.centres,
      dribble: row.dribble,
      controle: row.controle,
      coupsFrancs: row.coups_francs,
      corners: row.corners,
      penalties: row.penalties,
      frappesLointaines: row.frappes_lointaines,
      creativite: row.creativite,
      positionnement: row.positionnement,
      deplacement: row.deplacement,
      agressivite: row.agressivite,
      sangFroid: row.sang_froid,
      concentration: row.concentration,
      flair: row.flair,
      leadership: row.leadership,
      vitesse: row.vitesse,
      endurance: row.endurance,
      force: row.force,
      stabiliteAerienne: row.stabilite_aerienne,
      distanceParcourue: row.distance_parcourue,
    };
  }

  private mapToRow(stats: PlayerStats): any {
    return {
      joueur_id: stats.joueurId,
      save_id: stats.saveId,
      marquage: stats.marquage,
      tacles: stats.tacles,
      finition: stats.finition,
      passes: stats.passes,
      passes_longues: stats.passesLongues,
      centres: stats.centres,
      dribble: stats.dribble,
      controle: stats.controle,
      coups_francs: stats.coupsFrancs,
      corners: stats.corners,
      penalties: stats.penalties,
      frappes_lointaines: stats.frappesLointaines,
      creativite: stats.creativite,
      positionnement: stats.positionnement,
      deplacement: stats.deplacement,
      agressivite: stats.agressivite,
      sang_froid: stats.sangFroid,
      concentration: stats.concentration,
      flair: stats.flair,
      leadership: stats.leadership,
      vitesse: stats.vitesse,
      endurance: stats.endurance,
      force: stats.force,
      stabilite_aerienne: stats.stabiliteAerienne,
      distance_parcourue: stats.distanceParcourue,
    };
  }
}
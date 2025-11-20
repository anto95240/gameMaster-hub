import { supabase } from '@/lib/supabaseClient';
import { GoalkeeperStats } from '@/domain/entities/goalkeeper-stats';
import { IGoalkeeperStatsRepository } from '@/domain/interfaces/goalkeeper-stats-repository.interface';

export class SupabaseGoalkeeperStatsRepository implements IGoalkeeperStatsRepository {

  async getAllStats(saveId: number): Promise<GoalkeeperStats[]> {
    const { data, error } = await supabase
      .from('stats_gardien_sm')
      .select('*')
      .eq('save_id', saveId);

    if (error) throw new Error(error.message);
    return data.map(this.mapToEntity);
  }

  async getStatsByPlayerId(playerId: number, saveId: number): Promise<GoalkeeperStats | null> {
    const { data, error } = await supabase
      .from('stats_gardien_sm')
      .select('*')
      .match({ joueur_id: playerId, save_id: saveId })
      .maybeSingle();

    if (error) throw new Error(error.message);
    return data ? this.mapToEntity(data) : null;
  }

  async insertStats(stats: GoalkeeperStats): Promise<void> {
    const { error } = await supabase.from('stats_gardien_sm').insert(this.mapToRow(stats));
    if (error) throw new Error(error.message);
  }

  async updateStats(stats: GoalkeeperStats): Promise<void> {
    const { error } = await supabase
      .from('stats_gardien_sm')
      .update(this.mapToRow(stats))
      .eq('id', stats.id);
    if (error) throw new Error(error.message);
  }

  async deleteStats(id: number): Promise<void> {
    const { error } = await supabase.from('stats_gardien_sm').delete().eq('id', id);
    if (error) throw new Error(error.message);
  }

  private mapToEntity(row: any): GoalkeeperStats {
    return {
      id: row.id,
      joueurId: row.joueur_id,
      saveId: row.save_id,
      arrets: row.arrets,
      autoriteSurface: row.autorite_surface,
      distribution: row.distribution,
      captation: row.captation,
      duels: row.duels,
      positionnement: row.positionnement,
      penalties: row.penalties,
      stabiliteAerienne: row.stabilite_aerienne,
      vitesse: row.vitesse,
      force: row.force,
      agressivite: row.agressivite,
      sangFroid: row.sang_froid,
      concentration: row.concentration,
      leadership: row.leadership,
    };
  }

  private mapToRow(stats: GoalkeeperStats): any {
    return {
      joueur_id: stats.joueurId,
      save_id: stats.saveId,
      arrets: stats.arrets,
      autorite_surface: stats.autoriteSurface,
      distribution: stats.distribution,
      captation: stats.captation,
      duels: stats.duels,
      positionnement: stats.positionnement,
      penalties: stats.penalties,
      stabilite_aerienne: stats.stabiliteAerienne,
      vitesse: stats.vitesse,
      force: stats.force,
      agressivite: stats.agressivite,
      sang_froid: stats.sangFroid,
      concentration: stats.concentration,
      leadership: stats.leadership,
    };
  }
}
import { supabase } from '@/lib/supabaseClient';
import { Save } from '@/domain/entities/save';
import { ISaveRepository } from '@/domain/interfaces/save-repository.interface';

export class SupabaseSaveRepository implements ISaveRepository {

  async getSavesByGame(gameId: number): Promise<Save[]> {
    const { data, error } = await supabase
      .from('save')
      .select('*')
      .eq('game_id', gameId)
      .order('id', { ascending: false }); // Plus récent en premier

    if (error) throw new Error(error.message);
    return data.map(this.mapToEntity);
  }

  async getSaveById(saveId: number): Promise<Save | null> {
    const { data, error } = await supabase
      .from('save')
      .select('*')
      .eq('id', saveId)
      .maybeSingle();

    if (error) throw new Error(error.message);
    return data ? this.mapToEntity(data) : null;
  }

  async createSave(save: Save): Promise<number> {
    const { data, error } = await supabase
      .from('save')
      .insert({
        game_id: save.gameId,
        user_id: save.userId,
        name: save.name,
        description: save.description,
        is_active: save.isActive,
        number_of_players: save.numberOfPlayers,
        overall_rating: save.overallRating,
      })
      .select('id') // Important pour récupérer l'ID généré
      .single();

    if (error) throw new Error(error.message);
    return data.id;
  }

  async updateSave(save: Save): Promise<void> {
    const { error } = await supabase
      .from('save')
      .update({
        name: save.name,
        description: save.description,
        is_active: save.isActive,
        number_of_players: save.numberOfPlayers,
        overall_rating: save.overallRating,
      })
      .eq('id', save.id);

    if (error) throw new Error(error.message);
  }

  async deleteSave(saveId: number): Promise<void> {
    const { error } = await supabase.from('save').delete().eq('id', saveId);
    if (error) throw new Error(error.message);
  }

  // Stats simplifiées
  async countPlayersBySave(saveId: number): Promise<number> {
    const { count, error } = await supabase
      .from('joueur_sm')
      .select('*', { count: 'exact', head: true })
      .eq('save_id', saveId);
      
    if (error) throw new Error(error.message);
    return count || 0;
  }

  async averageRatingBySave(saveId: number): Promise<number> {
    // Note: Supabase ne fait pas d'aggregation directe AVG facilement sans RPC
    // Pour l'instant on retourne 0 ou on fait le calcul en JS si peu de données
    return 0; 
  }

  private mapToEntity(row: any): Save {
    return {
      id: row.id,
      gameId: row.game_id,
      userId: row.user_id,
      name: row.name,
      description: row.description,
      isActive: row.is_active,
      numberOfPlayers: row.number_of_players ?? 0,
      overallRating: row.overall_rating ?? 0,
    };
  }
}
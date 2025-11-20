import { supabase } from '@/lib/supabaseClient';
import { Game } from '@/domain/entities/game';
import { IGameRepository } from '@/domain/interfaces/game-repository.interface';

export class SupabaseGameRepository implements IGameRepository {
  
  async getAllGames(): Promise<Game[]> {
    const { data, error } = await supabase
      .from('game')
      .select('*')
      .order('name', { ascending: true });

    if (error) throw new Error(error.message);

    return data.map(this.mapToEntity);
  }

  async getGameById(id: number): Promise<Game | null> {
    const { data, error } = await supabase
      .from('game')
      .select('*')
      .eq('game_id', id)
      .maybeSingle();

    if (error) throw new Error(error.message);
    if (!data) return null;

    return this.mapToEntity(data);
  }

  // Non implémenté car logic "WithSaves" gérée souvent côté state management ou jointure spécifique
  async getAllGamesWithSaves(): Promise<Game[]> {
    return this.getAllGames();
  }
  async getGameByIdWithSaves(id: number): Promise<Game | null> {
    return this.getGameById(id);
  }

  private mapToEntity(row: any): Game {
    return {
      gameId: row.game_id,
      name: row.name,
      description: row.description,
      icon: row.icon,
      route: row.route,
      savesCount: row.saves_count ?? 0,
    };
  }
}
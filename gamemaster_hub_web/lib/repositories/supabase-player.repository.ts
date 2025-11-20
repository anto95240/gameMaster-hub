import { supabase } from '@/lib/supabaseClient';
import { Player } from '@/domain/entities/player';
import { IPlayerRepository } from '@/domain/interfaces/player-repository.interface';
import { PosteEnum, StatusEnum } from '@/domain/shared/enums';

export class SupabasePlayerRepository implements IPlayerRepository {

  async getAllPlayers(saveId: number): Promise<Player[]> {
    const { data, error } = await supabase
      .from('joueur_sm')
      .select('*')
      .eq('save_id', saveId);

    if (error) throw new Error(error.message);
    return data.map(this.mapToEntity);
  }

  async getPlayerById(id: number, saveId: number): Promise<Player | null> {
    const { data, error } = await supabase
      .from('joueur_sm')
      .select('*')
      .match({ id, save_id: saveId })
      .maybeSingle();

    if (error) throw new Error(error.message);
    return data ? this.mapToEntity(data) : null;
  }

  async insertPlayer(player: Player): Promise<void> {
    const { error } = await supabase.from('joueur_sm').insert(this.mapToRow(player));
    if (error) throw new Error(error.message);
  }

  async updatePlayer(player: Player): Promise<void> {
    const { error } = await supabase
      .from('joueur_sm')
      .update(this.mapToRow(player))
      .eq('id', player.id);
    if (error) throw new Error(error.message);
  }

  async deletePlayer(id: number): Promise<void> {
    const { error } = await supabase.from('joueur_sm').delete().eq('id', id);
    if (error) throw new Error(error.message);
  }

  private mapToEntity(row: any): Player {
    return {
      id: row.id,
      saveId: row.save_id,
      nom: row.nom,
      age: row.age,
      postes: (row.postes as string[]).map(p => p as PosteEnum), // Supabase renvoie un tableau JSON
      niveauActuel: row.niveau_actuel,
      potentiel: row.potentiel,
      montantTransfert: row.montant_transfert,
      status: row.status as StatusEnum,
      dureeContrat: row.duree_contrat,
      salaire: row.salaire,
      userId: row.user_id,
    };
  }

  private mapToRow(player: Player): any {
    return {
      // id: player.id, // On laisse la DB générer l'ID si c'est un insert
      save_id: player.saveId,
      nom: player.nom,
      age: player.age,
      postes: player.postes, // Sera converti en JSON array par Supabase JS
      niveau_actuel: player.niveauActuel,
      potentiel: player.potentiel,
      montant_transfert: player.montantTransfert,
      status: player.status,
      duree_contrat: player.dureeContrat,
      salaire: player.salaire,
      user_id: player.userId,
    };
  }
}
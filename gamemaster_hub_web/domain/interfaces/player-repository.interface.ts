import { Player } from "@/domain/entities/player";

export interface IPlayerRepository {
  getAllPlayers(saveId: number): Promise<Player[]>;
  getPlayerById(id: number, saveId: number): Promise<Player | null>;
  
  insertPlayer(player: Player): Promise<void>;
  updatePlayer(player: Player): Promise<void>;
  deletePlayer(id: number): Promise<void>;
}
import { PlayerStats } from "@/domain/entities/player-stats";

export interface IPlayerStatsRepository {
  getAllStats(saveId: number): Promise<PlayerStats[]>;
  getStatsByPlayerId(playerId: number, saveId: number): Promise<PlayerStats | null>;
  
  insertStats(stats: PlayerStats): Promise<void>;
  updateStats(stats: PlayerStats): Promise<void>;
  deleteStats(id: number): Promise<void>;
}
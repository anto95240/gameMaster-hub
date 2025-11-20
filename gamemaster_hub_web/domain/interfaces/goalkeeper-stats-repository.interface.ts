import { GoalkeeperStats } from "@/domain/entities/goalkeeper-stats";

export interface IGoalkeeperStatsRepository {
  getAllStats(saveId: number): Promise<GoalkeeperStats[]>;
  getStatsByPlayerId(playerId: number, saveId: number): Promise<GoalkeeperStats | null>;
  
  insertStats(stats: GoalkeeperStats): Promise<void>;
  updateStats(stats: GoalkeeperStats): Promise<void>;
  deleteStats(id: number): Promise<void>;
}
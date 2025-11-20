import { Game } from "@/domain/entities/game";

export interface IGameRepository {
  getAllGames(): Promise<Game[]>;
  getGameById(id: number): Promise<Game | null>;

  // Optionnels selon si vous gardez cette distinction en Front
  getAllGamesWithSaves(): Promise<Game[]>;
  getGameByIdWithSaves(id: number): Promise<Game | null>;
}
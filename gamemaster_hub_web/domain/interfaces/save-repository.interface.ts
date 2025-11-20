import { Save } from "@/domain/entities/save";

export interface ISaveRepository {
  getSavesByGame(gameId: number): Promise<Save[]>;
  getSaveById(saveId: number): Promise<Save | null>;
  
  createSave(save: Save): Promise<number>; // Retourne l'ID de la save créée
  updateSave(save: Save): Promise<void>;
  deleteSave(saveId: number): Promise<void>;

  countPlayersBySave(saveId: number): Promise<number>;
  averageRatingBySave(saveId: number): Promise<number>;
}
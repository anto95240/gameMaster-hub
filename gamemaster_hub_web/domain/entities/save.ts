// domain/entities/save.ts

export interface Save {
  id: number;
  gameId: number;
  userId: string;
  name: string;
  description?: string;
  isActive: boolean;
  numberOfPlayers: number;
  overallRating: number;
}
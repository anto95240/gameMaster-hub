// domain/entities/game.ts

export interface Game {
  gameId: number;
  name: string;
  description?: string;
  icon?: string;
  route?: string;
  savesCount: number;
}
// domain/entities/goalkeeper-stats.ts

export interface GoalkeeperStats {
  id: number;
  joueurId: number;
  saveId: number;

  // Technique
  autoriteSurface: number;
  distribution: number;
  captation: number;
  duels: number;
  arrets: number;
  positionnement: number;
  penalties: number;

  // Physique
  stabiliteAerienne: number;
  vitesse: number;
  force: number;

  // Mental
  agressivite: number;
  sangFroid: number;
  concentration: number;
  leadership: number;
}

export const createEmptyGoalkeeperStats = (joueurId: number = 0, saveId: number = 0): GoalkeeperStats => ({
  id: 0,
  joueurId,
  saveId,
  
  // Technique
  autoriteSurface: 0,
  distribution: 0,
  captation: 0,
  duels: 0,
  arrets: 0,
  positionnement: 0,
  penalties: 0,

  // Physique
  stabiliteAerienne: 0,
  vitesse: 0,
  force: 0,

  // Mental
  agressivite: 0,
  sangFroid: 0,
  concentration: 0,
  leadership: 0,
});
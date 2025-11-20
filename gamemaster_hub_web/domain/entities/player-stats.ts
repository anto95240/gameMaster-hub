// domain/entities/player-stats.ts

export interface PlayerStats {
  id: number;
  joueurId: number;
  saveId: number;
  
  // Technique
  marquage: number;
  tacles: number;
  positionnement: number;
  deplacement: number;
  finition: number;
  dribble: number;
  frappesLointaines: number;
  centres: number;
  controle: number;
  passesLongues: number;
  passes: number;
  penalties: number;
  coupsFrancs: number;
  corners: number;
  creativite: number;

  // Mental
  agressivite: number;
  sangFroid: number;
  concentration: number;
  flair: number;
  leadership: number;

  // Physique
  stabiliteAerienne: number;
  vitesse: number;
  endurance: number;
  force: number;
  distanceParcourue: number;
}

// Factory pour initialiser des stats vides (utile pour les formulaires)
export const createEmptyPlayerStats = (joueurId: number = 0, saveId: number = 0): PlayerStats => ({
  id: 0,
  joueurId,
  saveId,
  
  // Technique
  marquage: 0,
  tacles: 0,
  positionnement: 0,
  deplacement: 0,
  finition: 0,
  dribble: 0,
  frappesLointaines: 0,
  centres: 0,
  controle: 0,
  passesLongues: 0,
  passes: 0,
  penalties: 0,
  coupsFrancs: 0,
  corners: 0,
  creativite: 0,

  // Mental
  agressivite: 0,
  sangFroid: 0,
  concentration: 0,
  flair: 0,
  leadership: 0,

  // Physique
  stabiliteAerienne: 0,
  vitesse: 0,
  endurance: 0,
  force: 0,
  distanceParcourue: 0,
});
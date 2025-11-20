// domain/entities/player.ts
import { PosteEnum, StatusEnum } from "@/domain/shared/enums";

export interface Player {
  id: number;
  saveId: number;
  nom: string;
  age: number;
  postes: PosteEnum[];
  niveauActuel: number;
  potentiel: number;
  montantTransfert: number;
  status: StatusEnum;
  dureeContrat: number;
  salaire: number;
  userId: string;
}

// Factory method équivalente à JoueurSm.empty()
export const createEmptyPlayer = (): Player => ({
  id: 0,
  saveId: 0,
  nom: 'Vide',
  age: 0,
  postes: [],
  niveauActuel: 0,
  potentiel: 0,
  montantTransfert: 0,
  status: StatusEnum.Titulaire,
  dureeContrat: 0,
  salaire: 0,
  userId: '',
});
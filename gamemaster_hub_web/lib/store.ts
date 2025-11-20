import { create } from 'zustand'

interface GameState {
  games: any[]
  setGames: (games: any[]) => void
}

export const useGameStore = create<GameState>((set) => ({
  games: [],
  setGames: (games) => set({ games }),
}))
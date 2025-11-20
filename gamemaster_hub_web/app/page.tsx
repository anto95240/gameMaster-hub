'use client'
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabaseClient'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card' // Assurez-vous d'avoir ajouté le composant Card via shadcn si besoin, sinon utilisez des divs standards pour le test

// Interface basée sur votre GameModel Flutter
interface Game {
  game_id: number
  name: string
  description: string
  saves_count: number
}

export default function Home() {
  const [games, setGames] = useState<Game[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    async function fetchGames() {
      try {
        // Requete identique à celle de votre GameDatasource Flutter
        const { data, error } = await supabase
          .from('game')
          .select('*')
          .order('name', { ascending: true })

        if (error) throw error
        setGames(data || [])
      } catch (err: any) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    fetchGames()
  }, [])

  return (
    <main className="flex min-h-screen flex-col items-center p-24">
      <h1 className="text-4xl font-bold mb-8">GameMaster Hub (Next.js)</h1>
      
      {loading && <p>Chargement des jeux...</p>}
      {error && <p className="text-red-500">Erreur: {error}</p>}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 w-full max-w-4xl">
        {games.map((game) => (
          <div key={game.game_id} className="border rounded-lg p-4 shadow-sm hover:shadow-md transition">
            <h2 className="text-xl font-semibold">{game.name}</h2>
            <p className="text-gray-600 mt-2">{game.description}</p>
            <div className="mt-4 text-sm text-blue-600 font-medium">
              Sauvegardes: {game.saves_count}
            </div>
          </div>
        ))}
      </div>
    </main>
  )
}
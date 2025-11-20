#!/bin/bash
set -e

# Installer Flutter stable (sans toute l'historique Git)
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

# Activer le web
flutter config --enable-web

# Récupérer les dépendances
flutter pub get

# Vérifier les variables d'environnement
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "❌ Erreur : SUPABASE_URL ou SUPABASE_ANON_KEY non définies."
  exit 1
fi

# Construire le projet Web avec les variables injectées
flutter build web --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

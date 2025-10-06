#!/bin/bash
set -e

echo "🚀 Build Flutter Web pour Vercel"

# Installer Flutter stable
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi
export PATH="$PATH:$(pwd)/flutter/bin"

# Vérifier Flutter
flutter --version

# Activer le web
flutter config --enable-web

# Récupérer les dépendances
flutter pub get

# Build Web avec les variables d'environnement passées par Vercel
flutter build web --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

echo "✅ Build terminé. Le dossier build/web est prêt pour Vercel."

#!/bin/bash
# Installer Flutter
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

# Vérifier l'installation
flutter --version

# Activer le web
flutter config --enable-web

# Récupérer les dépendances
flutter pub get

# Construire le projet web
flutter build web

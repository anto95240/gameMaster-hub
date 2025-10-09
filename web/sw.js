// web/sw.js - Service Worker avec notification de mise à jour
const CACHE_NAME = 'game-master-hub-v1.0.3'; // Incrémentez à chaque nouvelle version

self.addEventListener('install', (event) => {
  console.log('Service Worker: Installation en cours...');
  // Force le nouveau SW à prendre le contrôle immédiatement après l'installation
  self.skipWaiting();
  
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll([
        '/',
        '/index.html',
        '/main.dart.js',
        '/flutter.js',
        '/manifest.json',
        '/icons/Icon-192.png',
        '/icons/Icon-512.png',
      ]);
    })
  );
});

self.addEventListener('activate', (event) => {
  console.log('Service Worker: Activation');
  
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('Service Worker: Suppression ancien cache', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      // Prend le contrôle de toutes les pages immédiatement
      return self.clients.claim();
    }).then(() => {
      // Notifie les clients qu'une nouvelle version est disponible
      return self.clients.matchAll().then((clients) => {
        clients.forEach((client) => {
          client.postMessage({
            type: 'NEW_VERSION_AVAILABLE',
            version: CACHE_NAME
          });
        });
      });
    })
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});
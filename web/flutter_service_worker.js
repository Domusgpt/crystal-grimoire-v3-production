// Minimal Service Worker for Flutter Web (Workaround)
const CACHE_NAME = 'flutter-minimal-cache-v1';
const RESOURCES_TO_PRECACHE = [
  '/',
  '/index.html',
  '/manifest.json',
  // Add other essential assets if known, but keep it minimal for now
  // e.g., '/assets/my_icon.png'
];

console.log('Minimal Service Worker: Loading...');

self.addEventListener('install', event => {
  console.log('Minimal Service Worker: Install Event');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('Minimal Service Worker: Caching pre-defined assets');
        return cache.addAll(RESOURCES_TO_PRECACHE);
      })
      .catch(err => {
        console.error('Minimal Service Worker: Pre-caching failed:', err);
      })
  );
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  console.log('Minimal Service Worker: Activate Event');
  // Clean up old caches if any (optional for this minimal version)
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('Minimal Service Worker: Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  return self.clients.claim();
});

self.addEventListener('fetch', event => {
  console.log('Minimal Service Worker: Fetching', event.request.url);
  // Network-first strategy
  event.respondWith(
    fetch(event.request)
      .catch(() => {
        console.log('Minimal Service Worker: Network fetch failed, trying cache for', event.request.url);
        return caches.match(event.request).then(response => {
          return response || new Response("Network error and not found in cache", {
            status: 404,
            statusText: "Not Found"
          });
        });
      })
  );
});

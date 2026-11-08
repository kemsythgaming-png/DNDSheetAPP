const CACHE = 'dnd5e-v1';
const OFFLINE_PAGE = '/';

// Beim Installieren: App-Shell cachen
self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c => c.addAll(['/'])).then(() => self.skipWaiting())
  );
});

// Beim Aktivieren: alten Cache leeren
self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

// Fetch: Cache-first für statische Assets, Network-first für alles andere
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  if (!e.request.url.startsWith('http')) return;
  // Hot-Reload in Vite (@vite, __vite) nie cachen
  if (e.request.url.includes('@vite') || e.request.url.includes('__vite') || e.request.url.includes('hot')) return;

  const isAsset = /\.(png|jpg|jpeg|gif|svg|ico|woff2?|ttf|eot|css|js)(\?.*)?$/.test(e.request.url);

  if (isAsset) {
    // Cache-first: static assets
    e.respondWith(
      caches.match(e.request).then(cached => {
        if (cached) return cached;
        return fetch(e.request).then(res => {
          if (res.ok) {
            const clone = res.clone();
            caches.open(CACHE).then(c => c.put(e.request, clone));
          }
          return res;
        });
      })
    );
  } else {
    // Network-first: HTML/API
    e.respondWith(
      fetch(e.request)
        .then(res => {
          if (res.ok) {
            const clone = res.clone();
            caches.open(CACHE).then(c => c.put(e.request, clone));
          }
          return res;
        })
        .catch(() => caches.match(e.request).then(cached => cached || caches.match(OFFLINE_PAGE)))
    );
  }
});

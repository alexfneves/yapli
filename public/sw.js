const CACHE_NAME = "yapli-cache-v1";
const assetsToCache = [
  "/",
  "/index.html",
  "/manifest.json",
  "/out.data",
  "/out.js",
  "/out.wasm",
  "/study-abroad128.png",
  "/study-abroad512.png",
  "/sw.js",
];

// self.addEventListener("install", (evt) => {
//   evt.waitUntil(
//     caches.open(CACHE_NAME).then((cache) => cache.addAll(assetsToCache)),
//   );
// });

// self.addEventListener("fetch", (evt) => {
//   evt.respondWith(
//     caches.match(evt.request).then((res) => res || fetch(evt.request)),
//   );
// });

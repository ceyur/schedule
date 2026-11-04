{{flutter_js}}
{{flutter_build_config}}

if ('serviceWorker' in navigator) {
  navigator.serviceWorker
    .register('./sw.js', { scope: '/schedule/' })
    .then(reg => console.log('Service Worker зарегистрирован, scope:', reg.scope))
    .catch(err => console.error('Ошибка регистрации Service Worker:', err));
}

_flutter.loader.load();

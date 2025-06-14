// Firebase Messaging Service Worker for web push notifications
importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-messaging-compat.js');

// Initialize Firebase in service worker
firebase.initializeApp({
  apiKey: 'AIzaSyCfaw8I-rwXu8j0El340yIGr-N2agTzp6c',
  authDomain: 'crystalgrimoire-production.firebaseapp.com',
  projectId: 'crystalgrimoire-production',
  storageBucket: 'crystalgrimoire-production.firebasestorage.app',
  messagingSenderId: '937741022651',
  appId: '1:937741022651:web:cf181d053f178c9298c09e',
  measurementId: 'G-QHLRSZ48WN',
});

// Initialize Firebase Messaging
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('Received background message: ', payload);
  
  const notificationTitle = payload.notification.title || 'Crystal Grimoire';
  const notificationOptions = {
    body: payload.notification.body || 'New crystal insight available!',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data,
    actions: [
      {
        action: 'open',
        title: 'Open Crystal Grimoire'
      }
    ]
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification clicks
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  
  event.waitUntil(
    clients.openWindow('/')
  );
});
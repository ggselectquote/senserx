importScripts("https://www.gstatic.com/firebasejs/8.2.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.2.0/firebase-messaging.js");



firebase.initializeApp({
    authDomain: "senserx.firebaseapp.com",
    apiKey: 'AIzaSyDGDFOwyrrf23IviBKWND8nlp4K3HM_US4',
    appId: '1:781900009201:android:652246ab0e8a5ecdcbe350',
    messagingSenderId: '781900009201',
    projectId: 'senserx',
    storageBucket: 'senserx.firebasestorage.app'
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
    console.log("Firebase Message (Background):", payload);

    const notificationTitle = payload.notification?.title || "Default Title";
    const notificationOptions = {
        body: payload.notification?.body || "Default Body",
        icon: payload.notification?.icon || "/default-icon.png",
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});

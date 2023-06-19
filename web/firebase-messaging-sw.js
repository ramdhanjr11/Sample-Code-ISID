importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

const firebaseConfig = {
    apiKey: "AIzaSyAKToaX_AGnXWi-VQGAleLBWL_znRm6gq4",
    authDomain: "isid-push-notification-6dad3.firebaseapp.com",
    projectId: "isid-push-notification-6dad3",
    storageBucket: "isid-push-notification-6dad3.appspot.com",
    messagingSenderId: "541073163713",
    appId: "1:541073163713:web:583c37c4809f68934a9b40",
    measurementId: "G-B278QMB1N9"
};

firebase.initializeApp(firebaseConfig);

// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((payload) => {
    console.log("onBackgroundMessage", payload);
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});
import { initializeApp } from "firebase/app";
import { getMessaging, getToken, onMessage } from "firebase/messaging";
import { Toast } from '../components/Toast';

export const firebaseConfig = {
    authDomain: "senserx.firebaseapp.com",
    apiKey: 'AIzaSyDGDFOwyrrf23IviBKWND8nlp4K3HM_US4',
    appId: '1:781900009201:android:652246ab0e8a5ecdcbe350',
    messagingSenderId: '781900009201',
    projectId: 'senserx',
    storageBucket: 'senserx.firebasestorage.app',
};
const firebaseApp = initializeApp(firebaseConfig);
const messaging = getMessaging(firebaseApp);

const setupNotifications = async () => {
    try {
      // Request permission for notifications
      const permission = await Notification.requestPermission();
      
      if (permission === 'granted') {
        console.log('Notification permission granted.');
        // Get the FCM token
        const token = await getToken(messaging);
        //console.log('FCM Token:', token);
      } else {
        console.log('Notification permission denied.');
      }

      onMessage(messaging, (payload) => {
        console.log('Firebase Message:', payload);
        
        Toast.info(
          "payload.notification?.title"
            // <p>
            //     <strong>"{payload.notification?.title}"</strong>
            //     <br />
            //     "{payload.notification?.body}"
            // </p>,
        );
    });
    } catch (error) {
      console.error('Error setting up notifications:', error);
    }
  };
  export { messaging, setupNotifications };

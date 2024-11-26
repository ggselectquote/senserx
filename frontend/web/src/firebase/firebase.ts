import { initializeApp } from "firebase/app";
import { getMessaging, getToken, onMessage } from "firebase/messaging";
import { Toast } from '../components/Toast';
import { firebaseConfig } from "./firebaseConfig";

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

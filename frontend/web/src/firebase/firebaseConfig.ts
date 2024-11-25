import { initializeApp } from '@firebase/app';
import { getMessaging, getToken } from '@firebase/messaging';

export const firebaseConfig = {
    authDomain: "senserx.firebaseapp.com",
    apiKey: 'BF_f9HNEBWPJPrnuRjMRriw2aq1pQlfOaOI0fEtVtL1Bf_ntj8_1B6ZvyZg9FU57vNSgSqqzVzeKhb6BCj_MBWg',
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
      console.log('FCM Token:', token);
    } else {
      console.log('Notification permission denied.');
    }
  } catch (error) {
    console.error('Error setting up notifications:', error);
  }
};
export { messaging, setupNotifications };

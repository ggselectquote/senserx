import firebase from 'firebase/compat/app';
import 'firebase/compat/auth';
import 'firebase/compat/database';

const firebaseConfig = {
    authDomain: "senserx.firebaseapp.com",
    apiKey: 'BF_f9HNEBWPJPrnuRjMRriw2aq1pQlfOaOI0fEtVtL1Bf_ntj8_1B6ZvyZg9FU57vNSgSqqzVzeKhb6BCj_MBWg',
    appId: '1:781900009201:android:652246ab0e8a5ecdcbe350',
    messagingSenderId: '781900009201',
    projectId: 'senserx',
    storageBucket: 'senserx.firebasestorage.app',
};

// Initialize Firebase
if (!firebase.apps.length) {
    firebase.initializeApp(firebaseConfig);
}

export const FirebaseAuth = firebase.auth();
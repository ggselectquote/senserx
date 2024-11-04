import firebase from 'firebase/app';
import 'firebase/auth';

const firebaseConfig = {
};

// Initialize Firebase
if (!firebase.apps.length) {
    firebase.initializeApp(firebaseConfig);
}

export const FirebaseAuth = firebase.auth();
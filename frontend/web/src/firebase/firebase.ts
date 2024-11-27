import { initializeApp } from "firebase/app";
import { getMessaging, getToken, onMessage } from "firebase/messaging";
import { Toast } from "../components/Toast";
import { firebaseConfig } from "./firebaseConfig";


const firebaseApp = initializeApp(firebaseConfig);
const messaging = getMessaging(firebaseApp);

const setupNotifications = async () => {
  try {
    const permission = await Notification.requestPermission();

    if (permission === "granted") {
      console.log("Notification permission granted.");

      const fcmToken = await getToken(messaging);
      console.log("FCM Token:", fcmToken);

      const platform = navigator.platform || "Unknown";
      const osVersion = navigator.userAgent || "Unknown";

      const response = await fetch("/mobile-devices", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          deviceId: await getDeviceId(),
          platform,
          osVersion,
          fcmToken,
          facilityId: "e3168780-d504-4fbc-9916-f216621644db", // or yer own fasilitee
        }),
      });

      if (!response.ok) {
        throw new Error("Failed to register device with backend");
      }
      console.log("Device registered successfully:", await response.json());
      onMessage(messaging, (payload) => {
        console.log("Firebase Message (Foreground):", payload);

        if (payload.notification) {
          Toast.info(
              `${payload.notification.title}\n${payload.notification.body}`
          );
        }
      });
    } else {
      console.log("Notification permission denied.");
    }
  } catch (error) {
    console.error("Error setting up notifications:", error);
  }
};

const getDeviceId = async () => {
  const storedId = localStorage.getItem("deviceId");
  if (storedId) {
    return storedId;
  }
  const newId = crypto.randomUUID();
  localStorage.setItem("deviceId", newId);
  return newId;
};

export { messaging, setupNotifications };

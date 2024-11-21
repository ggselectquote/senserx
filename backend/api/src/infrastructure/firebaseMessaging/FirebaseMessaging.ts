import admin from 'firebase-admin';
import serviceAccount from '../../../senserx-firebase-adminsdk-h9drf-3efdc54ebd.json';
import { NotificationEvent } from "../../application/events/NotificationEvent";

import dotenv from 'dotenv';
dotenv.config();

export class FirebaseMessaging {
    private firebaseAdmin?: admin.app.App;

    constructor() {
        if (!admin.apps.length) {
            this.firebaseAdmin = admin.initializeApp({
                credential: admin.credential.cert(serviceAccount as admin.ServiceAccount)
            });
        }
    }

    /**
     * Send notification to multiple devices
     * @param tokens - Array of device FCM tokens
     * @param event - NotificationEvent object containing title, body, and data
     */
    async sendNotification(tokens: string[], event: NotificationEvent): Promise<void> {
        const message = {
            notification: {
                title: event.title,
                body: event.body,
            },
            data: event.data,
            tokens: tokens,
        };

        try {
            const response = await this.firebaseAdmin?.messaging().sendEachForMulticast(message);
            if (!response) throw Error("No response");
            console.log(`Notification sent to ${response.successCount} devices`);
            if (response.failureCount > 0) {
                console.error(`Failed to send notification to ${response.failureCount} devices`);
            }
        } catch (error) {
            console.error('Error sending notification:', error);
        }
    }
}
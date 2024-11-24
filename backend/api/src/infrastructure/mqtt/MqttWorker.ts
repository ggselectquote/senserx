import { parentPort } from 'worker_threads';
import mqtt, {MqttClient} from 'mqtt';
import {Channels} from "../../domain/enums/Channels";

const host = process.env.MQTT_SERVER_URL || 'localhost';
const port = process.env.MQTT_SERVER_PORT || '1883';
const clientId = `mqtt_${Math.random().toString(16).slice(3)}`;
const connectUrl = `mqtt://${host}:${port}`;


let client: MqttClient;
let reconnectAttempts = 0;
const maxReconnectAttempts = 10;

function log(message: string, type = 'info') {
    const logMessage = { type, message, timestamp: new Date().toISOString() };
    console.log(JSON.stringify(logMessage));
    if (parentPort) {
        parentPort.postMessage(logMessage);
    }
}

function connect() {
    log('Attempting to connect to MQTT broker');

    client = mqtt.connect(connectUrl, {
        clientId,
        clean: true,
        connectTimeout: 4000,
        username: process.env.MQTT_USERNAME,
        password: process.env.MQTT_PASSWORD,
        reconnectPeriod: 1000,
    });

    client.on('connect', () => {
        log(`Connected to MQTT broker: ${connectUrl}`);
        reconnectAttempts = 0;

        client.subscribe([Channels.SHELVES, Channels.FIREBASE_MESSAGING + "/#"], (err) => {
            if (err) {
                log(`Failed to subscribe to topics: ${err.message}`, 'error');
            } else {
                log(`Subscribed to topics`);
            }
        });
    });

    client.on('message', (topic, payload) => {
        //log(`Received message on topic '${topic}': ${payload.toString()}`);
        if (parentPort) {
            parentPort.postMessage({ type: 'message', topic, message: payload.toString() });
        }
    });

    client.on('error', (err) => {
        log(`MQTT error: ${err.message}`, 'error');
    });

    client.on('close', () => {
        log('MQTT connection closed');
    });

    client.on('offline', () => {
        log('MQTT client is offline');
    });

    client.on('reconnect', () => {
        reconnectAttempts++;
        log(`Attempting to reconnect (${reconnectAttempts}/${maxReconnectAttempts})`);
        if (reconnectAttempts >= maxReconnectAttempts) {
            log('Max reconnection attempts reached. Stopping reconnection.', 'error');
            client.end(true);
        }
    });
}

connect();

parentPort?.on('message', (msg) => {
    if (msg === 'exit') {
        log('Received exit command. Closing MQTT connection.');
        client.end(true, () => {
            log('MQTT disconnected');
            process.exit(0);
        });
    }
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
    log(`Uncaught Exception: ${error.message}`, 'error');
    if (client) client.end(true);
    process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
    log(`Unhandled Rejection at: ${promise}\nReason: ${reason}`, 'error');
});

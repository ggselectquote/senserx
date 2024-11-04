import { parentPort } from 'worker_threads';
import mqtt from 'mqtt';

const host = process.env.MQTT_SERVER_URL || 'localhost';
const port = process.env.MQTT_SERVER_PORT || '1883';
const clientId = `mqtt_${Math.random().toString(16).slice(3)}`;
const connectUrl = `${host}:${port}`;
const topic = 'senserx';

/**
 * boot the mqtt client
 */
const client = mqtt.connect(connectUrl, {
    clientId,
    clean: true,
    connectTimeout: 4000,
    username: process.env.MQTT_USERNAME,
    password: process.env.MQTT_PASSWORD,
    reconnectPeriod: 1000,
});

/**
 * @listens connect
 */
client.on('connect', () => {
    client.subscribe([topic], () => {
        console.log(`Subscribed to topic '${topic}'`);
    });
    client.publish(topic, 'mqtt worker started', { qos: 0, retain: false }, (error) => {
        if (error) {
            console.error(error);
        }
    });
});

/**
 * @listens message
 */
client.on('message', (topic, payload) => {
    if (parentPort) {
        parentPort.postMessage({ topic: topic, message: payload.toString() });
    }
    client.on('error', (err) => {
        console.error('mqtt error: ', err);
        if (parentPort) {
            parentPort.postMessage({ error: err.message });
        }
    });
});

/**
 * onMessage
 */
parentPort?.on('message', (msg) => {
    if (msg === 'exit') {
        client.end(true, () => {
            console.log('mqtt disconnected');
        });
    }
});
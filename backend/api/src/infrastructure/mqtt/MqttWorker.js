import { parentPort } from 'worker_threads';
import mqtt from 'mqtt';

const protocol = 'mqtt';
const host = process.env.MQTT_SERVER_URL || 'localhost';
const port = process.env.MQTT_SERVER_PORT || '1883';
const clientId = `mqtt_${Math.random().toString(16).slice(3)}`;
const connectUrl = `${protocol}://${host}:${port}`;
const topic = 'shelves';

const client = mqtt.connect(connectUrl, {
    clientId,
    clean: true,
    connectTimeout: 4000,
    username: process.env.MQTT_USERNAME,
    password: process.env.MQTT_PASSWORD,
    reconnectPeriod: 1000,
});

client.on('connect', () => {
    console.log('Connected to MQTT broker');

    client.subscribe([topic], () => {
        console.log(`Subscribed to topic '${topic}'`);
    });

    client.publish(topic, 'MQTT Worker started', { qos: 0, retain: false }, (error) => {
        if (error) {
            console.error(error);
        }
    });
});

client.on('message', (topic, payload) => {
    console.log(`MQTT Worker received message on topic "${topic}":`, payload.toString());
    if (parentPort) {
        parentPort.postMessage({ topic: topic, message: payload.toString() });
    }
    client.on('error', (err) => {
        console.error('MQTT Worker Error:', err);
        if (parentPort) {
            parentPort.postMessage({ error: err.message });
        }
    });
});

parentPort.on('message', (msg) => {
    if (msg === 'exit') {
        client.end(true, () => {
            console.log('MQTT Worker disconnected');
        });
    }
});
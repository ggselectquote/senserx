import {Worker} from "worker_threads";
import path from "node:path";

const mqttWorker = new Worker(path.join(__dirname,
    `workers/MqttWorker.js`
));

mqttWorker.on('message', (msg: any) => {
    if (msg.error) {
        console.error('MQTT Error:', msg.error);
    } else {
        console.log(`Main thread received message from MQTT worker on topic "${msg.topic}":`, msg.message);
    }
});
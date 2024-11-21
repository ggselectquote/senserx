#ifndef MQTT_H
#define MQTT_H

#include "esp_err.h"
#include "mqtt_client.h"
#include "../Definitions/Definitions.h"

/**
 * Send a JSON message over MQTT.
 * 
 * @param topic The MQTT topic to publish the message to.
 * @param json_message The JSON message to publish.
 * 
 * @return ESP_OK on success, ESP_FAIL on failure.
 */
esp_err_t mqtt_send_message(const char *topic, const char *json_message);

/**
 * Sends a generic heartbeat message
 * 
 * @param client The MQTT client to publish on
 * 
 * @return void
 */
void send_heartbeat_message(esp_mqtt_client_handle_t client, const SignalMessage *signalMsg);
/**
 * Starts the MQTT task.  SEE credentials_template.h for instructions.
 * 
 * @param pvParameters Task params
 * 
 * @return void
 */
void start_mqtt_task(void *pvParameters);

#endif // MQTT_H